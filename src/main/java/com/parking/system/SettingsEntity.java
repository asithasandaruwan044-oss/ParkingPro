package com.parking.system;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "settings")
@Data
public class SettingsEntity {
    @Id
    private Integer id = 1; // අපිට අවශ්‍ය වන්නේ එක පේළියක් පමණයි

    private Integer totalSlots;
    private Integer ratePerMinute;
}