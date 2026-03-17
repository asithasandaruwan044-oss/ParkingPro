package com.parking.system;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "vehicles")
@Data
public class VehicleEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String slot;
    private String vehicleNumber;
    private String ownerName;
    private String model;
    private String entryTime;
    private String customerType;
    private String imageName;
    private String entryUser;
}