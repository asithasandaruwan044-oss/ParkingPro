package com.parking.system;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.servlet.http.HttpSession;
import java.util.*;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.ui.Model;
import java.io.*;

@Controller
public class LoginController {

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
    public String showDashboard(Model model) {
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
                             @RequestParam("vehicleImage") MultipartFile file, HttpSession session) {
        try {
            String entryUser = (String) session.getAttribute("userName");
            if (entryUser == null) entryUser = "System";

            // 1. Duplicate Check
            List<VehicleEntity> currentVehicles = vehicleRepository.findAll();
            Optional<VehicleEntity> duplicate = currentVehicles.stream()
                    .filter(v -> v.getVehicleNumber().equalsIgnoreCase(vNumber.trim()))
                    .findFirst();

            if (duplicate.isPresent()) {
                session.setAttribute("error", "Vehicle " + vNumber + " is already parked in " + duplicate.get().getSlot() + "!");
                return "redirect:/dashboard";
            }

            int totalSlots = getTotalSlots();
            if (currentVehicles.size() < totalSlots) {
                String assignedSlot = "";
                for (int i = 1; i <= totalSlots; i++) {
                    String slotName = "Slot-" + String.format("%02d", i);
                    boolean isOccupied = false;
                    for (VehicleEntity v : currentVehicles) {
                        if (v.getSlot().equals(slotName)) { isOccupied = true; break; }
                    }
                    if (!isOccupied) { assignedSlot = slotName; break; }
                }

                String fileName = "default.jpg";
                if (!file.isEmpty()) {
                    String uploadDir = new File("src/main/resources/static/images/uploaded_images/").getAbsolutePath();
                    File dir = new File(uploadDir);
                    if (!dir.exists()) dir.mkdirs();
                    fileName = vNumber.trim().replaceAll("\\s+", "_") + "_" + System.currentTimeMillis() + ".jpg";
                    file.transferTo(new File(dir + File.separator + fileName));
                }

                VehicleEntity newVehicle = new VehicleEntity();
                newVehicle.setSlot(assignedSlot);
                newVehicle.setVehicleNumber(vNumber.trim());
                newVehicle.setOwnerName(owner.trim());
                newVehicle.setModel(model.trim());
                newVehicle.setEntryTime(LocalDateTime.now().format(formatter));
                newVehicle.setCustomerType(customerType);
                newVehicle.setImageName(fileName);
                newVehicle.setEntryUser(entryUser);

                vehicleRepository.save(newVehicle);
            } else {
                session.setAttribute("error", "Parking is Full!");
            }
        } catch (IOException e) { e.printStackTrace(); }
        return "redirect:/dashboard";
    }

    @GetMapping("/deleteVehicle")
    public String deleteVehicle(@RequestParam String vNumber, HttpSession session, Model model) {
        String exitUser = (String) session.getAttribute("userName");
        if (exitUser == null) exitUser = "System";

        List<VehicleEntity> vehiclesFound = vehicleRepository.findAll();
        VehicleEntity v = null;
        for (VehicleEntity currentV : vehiclesFound) {
            if (currentV.getVehicleNumber().trim().equalsIgnoreCase(vNumber.trim())) {
                v = currentV;
                break;
            }
        }

        if (v != null) {
            LocalDateTime entryTime = LocalDateTime.parse(v.getEntryTime(), formatter);
            LocalDateTime exitTime = LocalDateTime.now();
            Duration duration = Duration.between(entryTime, exitTime);

            long totalSeconds = duration.getSeconds();
            long minutes = (long) Math.ceil(totalSeconds / 60.0);
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

            String exitDateTime = h.getExitTime();
            String dateOnly = exitDateTime.split(" ")[0];
            String monthOnly = dateOnly.substring(0, 7);

            dailyEarnings.put(dateOnly, dailyEarnings.getOrDefault(dateOnly, 0L) + fee);
            monthlyEarnings.put(monthOnly, monthlyEarnings.getOrDefault(monthOnly, 0L) + fee);

            if (dateOnly.equals(todayDate)) {
                todayEarnings += fee;
            }
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

    @GetMapping("/deleteLog")
    public String deleteLog(@RequestParam("id") Long id, HttpSession session, RedirectAttributes redirectAttributes) {
        // Admin කෙනෙක් නෙමෙයි නම් ලොග් වෙන්න කියන්න
        if (!"ADMIN".equals(session.getAttribute("userRole"))) {
            return "redirect:/login";
        }

        try {
            // Database එකෙන් අදාළ Record එක මකනවා
            historyRepository.deleteById(id);
            redirectAttributes.addFlashAttribute("success", "Log record deleted successfully!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error deleting record: " + e.getMessage());
        }

        return "redirect:/history";
    }
}