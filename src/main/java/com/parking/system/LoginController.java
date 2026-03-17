package com.parking.system;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Controller
public class LoginController {

    // Cloudinary Configuration
    private final Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
            "cloud_name", "dzdt83ztu",
            "api_key", "314498547929599",
            "api_secret", "rqHZwHq8wAdmRsV0jgUa2y2Tosw",
            "secure", true
    ));

    private final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private HistoryRepository historyRepository;

    @Autowired
    private SettingsRepository settingsRepository;

    @GetMapping("/login")
    public String showLoginPage() {
        return "login";
    }

    @GetMapping("/")
    public String index() {
        return "redirect:/login";
    }

    @PostMapping("/login")
    public String login(@RequestParam String username, @RequestParam String password, HttpSession session, Model model) {
        Optional<UserEntity> user = userRepository.findByUsername(username);
        if (user.isPresent() && user.get().getPassword().equals(password)) {
            session.setAttribute("userRole", user.get().getRole());
            session.setAttribute("userName", username);
            return "redirect:/dashboard";
        }
        model.addAttribute("error", "Invalid Credentials!");
        return "login";
    }

    @GetMapping("/dashboard")
    public String showDashboard(Model model, HttpSession session) {
        if (session.getAttribute("userName") == null) return "redirect:/login";

        List<VehicleEntity> vehicleList = vehicleRepository.findAll();
        int totalSlots = getTotalSlots();

        model.addAttribute("totalSlots", totalSlots);
        model.addAttribute("vehicles", vehicleList);
        model.addAttribute("availableSlots", totalSlots - vehicleList.size());
        return "dashboard";
    }

    @PostMapping("/addVehicle")
    public String addVehicle(@RequestParam String vNumber, @RequestParam String owner,
                             @RequestParam String model, @RequestParam String customerType,
                             @RequestParam("vehicleImage") MultipartFile file,
                             HttpSession session, RedirectAttributes ra) {
        try {
            String entryUser = (String) session.getAttribute("userName");
            if (entryUser == null) entryUser = "System";

            // 1. Duplicate Check - Database එකෙන්ම කෙලින්ම check කරනවා
            List<VehicleEntity> allActive = vehicleRepository.findAll();
            boolean isAlreadyParked = allActive.stream()
                    .anyMatch(v -> v.getVehicleNumber().equalsIgnoreCase(vNumber.trim()));

            if (isAlreadyParked) {
                ra.addFlashAttribute("error", "Vehicle " + vNumber + " is already parked!");
                return "redirect:/dashboard";
            }

            int totalSlots = getTotalSlots();
            if (allActive.size() < totalSlots) {
                // Slot Assignment Logic
                String assignedSlot = "Slot-00";
                for (int i = 1; i <= totalSlots; i++) {
                    String slotName = "Slot-" + String.format("%02d", i);
                    boolean isOccupied = allActive.stream().anyMatch(v -> v.getSlot().equals(slotName));
                    if (!isOccupied) {
                        assignedSlot = slotName;
                        break;
                    }
                }

                // Cloudinary Upload
                String finalImageUrl = "https://res.cloudinary.com/dzdt83ztu/image/upload/v12345678/default-car.png";
                if (file != null && !file.isEmpty()) {
                    Map uploadResult = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.emptyMap());
                    finalImageUrl = (String) uploadResult.get("secure_url");
                }

                VehicleEntity newVehicle = new VehicleEntity();
                newVehicle.setSlot(assignedSlot);
                newVehicle.setVehicleNumber(vNumber.trim().toUpperCase());
                newVehicle.setOwnerName(owner.trim());
                newVehicle.setModel(model.trim());
                newVehicle.setEntryTime(LocalDateTime.now().format(formatter));
                newVehicle.setCustomerType(customerType);
                newVehicle.setImageName(finalImageUrl);
                newVehicle.setEntryUser(entryUser);

                vehicleRepository.save(newVehicle);
                ra.addFlashAttribute("success", "Vehicle Added Successfully!");
            } else {
                ra.addFlashAttribute("error", "Parking is Full!");
            }
        } catch (IOException e) {
            ra.addFlashAttribute("error", "Image Upload Failed!");
            e.printStackTrace();
        }
        return "redirect:/dashboard";
    }

    @GetMapping("/deleteVehicle")
    public String deleteVehicle(@RequestParam String vNumber, HttpSession session, Model model) {
        if (session.getAttribute("userName") == null) return "redirect:/login";

        String exitUser = (String) session.getAttribute("userName");

        Optional<VehicleEntity> vehicleOpt = vehicleRepository.findAll().stream()
                .filter(v -> v.getVehicleNumber().equalsIgnoreCase(vNumber.trim()))
                .findFirst();

        if (vehicleOpt.isPresent()) {
            VehicleEntity v = vehicleOpt.get();
            LocalDateTime entryTime = LocalDateTime.parse(v.getEntryTime(), formatter);
            LocalDateTime exitTime = LocalDateTime.now();
            Duration duration = Duration.between(entryTime, exitTime);

            long minutes = (long) Math.ceil(duration.getSeconds() / 60.0);
            if (minutes < 1) minutes = 1;

            int rate = getRatePerMinute();
            long fee = minutes * rate;

            HistoryEntity history = new HistoryEntity();
            history.setSlot(v.getSlot());
            history.setVehicleNumber(v.getVehicleNumber());
            history.setOwnerName(v.getOwnerName());
            history.setFee((double) fee);
            history.setEntryTime(v.getEntryTime());
            history.setExitTime(exitTime.format(formatter));
            history.setImageName(v.getImageName());
            history.setHandledBy(v.getEntryUser() + " | " + exitUser);

            historyRepository.save(history);
            vehicleRepository.delete(v);

            model.addAttribute("vNumber", v.getVehicleNumber());
            model.addAttribute("owner", v.getOwnerName());
            model.addAttribute("minutes", minutes);
            model.addAttribute("fee", fee);
            return "invoice";
        }
        return "redirect:/dashboard";
    }

    @GetMapping("/history")
    public String showHistory(HttpSession session, Model model) {
        if (session.getAttribute("userName") == null) return "redirect:/login";

        List<HistoryEntity> historyList = historyRepository.findAll();
        Collections.reverse(historyList);

        long totalEarnings = 0;
        long todayEarnings = 0;
        Map<String, Long> dailyEarnings = new TreeMap<>(Collections.reverseOrder());
        Map<String, Long> monthlyEarnings = new TreeMap<>(Collections.reverseOrder());

        String todayDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

        for (HistoryEntity h : historyList) {
            long fee = h.getFee().longValue();
            totalEarnings += fee;

            String dateOnly = h.getExitTime().split(" ")[0];
            String monthOnly = dateOnly.substring(0, 7);

            dailyEarnings.put(dateOnly, dailyEarnings.getOrDefault(dateOnly, 0L) + fee);
            monthlyEarnings.put(monthOnly, monthlyEarnings.getOrDefault(monthOnly, 0L) + fee);

            if (dateOnly.equals(todayDate)) todayEarnings += fee;
        }

        model.addAttribute("historyLogs", historyList);
        model.addAttribute("totalEarnings", totalEarnings);
        model.addAttribute("todayEarnings", todayEarnings);
        model.addAttribute("dailyEarnings", dailyEarnings);
        model.addAttribute("monthlyEarnings", monthlyEarnings);

        return "history";
    }

    @GetMapping("/userManagement")
    public String userManagement(HttpSession session, Model model) {
        if (!"ADMIN".equals(session.getAttribute("userRole"))) return "redirect:/dashboard";
        model.addAttribute("allUsers", userRepository.findAll());
        return "userManagement";
    }

    @PostMapping("/addUser")
    public String addUser(@RequestParam String newUsername, @RequestParam String newPassword, @RequestParam String role, HttpSession session) {
        if ("ADMIN".equals(session.getAttribute("userRole"))) {
            UserEntity newUser = new UserEntity();
            newUser.setUsername(newUsername);
            newUser.setPassword(newPassword);
            newUser.setRole(role);
            userRepository.save(newUser);
        }
        return "redirect:/userManagement";
    }

    @GetMapping("/deleteUser")
    public String deleteUser(@RequestParam String username, HttpSession session) {
        if ("ADMIN".equals(session.getAttribute("userRole"))) {
            userRepository.findByUsername(username).ifPresent(userRepository::delete);
        }
        return "redirect:/userManagement";
    }

    @GetMapping("/adminSettings")
    public String showSettings(HttpSession session, Model model) {
        if (!"ADMIN".equals(session.getAttribute("userRole"))) return "redirect:/dashboard";
        model.addAttribute("totalSlots", getTotalSlots());
        model.addAttribute("currentRate", getRatePerMinute());
        return "adminSettings";
    }

    @PostMapping("/updateSettings")
    public String updateSettings(@RequestParam int newLimit, @RequestParam int newRate, HttpSession session, RedirectAttributes ra) {
        if ("ADMIN".equals(session.getAttribute("userRole"))) {
            SettingsEntity settings = settingsRepository.findById(1).orElse(new SettingsEntity());
            settings.setTotalSlots(newLimit);
            settings.setRatePerMinute(newRate);
            settingsRepository.save(settings);
        }
        ra.addFlashAttribute("msg", "Settings Updated Successfully!");
        return "redirect:/adminSettings";
    }

    @GetMapping("/deleteLog")
    public String deleteLog(@RequestParam("id") Long id, HttpSession session, RedirectAttributes ra) {
        if (!"ADMIN".equals(session.getAttribute("userRole"))) return "redirect:/login";
        try {
            historyRepository.deleteById(id);
            ra.addFlashAttribute("success", "Log record deleted successfully!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Error deleting record!");
        }
        return "redirect:/history";
    }

    private int getRatePerMinute() {
        return settingsRepository.findById(1).map(SettingsEntity::getRatePerMinute).orElse(2);
    }

    private int getTotalSlots() {
        return settingsRepository.findById(1).map(SettingsEntity::getTotalSlots).orElse(10);
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}