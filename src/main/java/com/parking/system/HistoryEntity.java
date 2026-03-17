package com.parking.system;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "history")
@Data
public class HistoryEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String slot;
    private String vehicleNumber;
    private String ownerName;
    private Double fee;
    private String entryTime;
    private String exitTime;
    private String imageName;
    private String handledBy;
}