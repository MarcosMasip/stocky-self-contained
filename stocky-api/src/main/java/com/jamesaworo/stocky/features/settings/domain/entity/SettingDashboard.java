package com.jamesaworo.stocky.features.settings.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import static com.jamesaworo.stocky.core.constants.Table.SETTING_DASHBOARD;

@Entity
@Table(name = SETTING_DASHBOARD)
public class SettingDashboard extends Setting {

    public SettingDashboard() {
    }


    public SettingDashboard(SettingObj obj) {
        super(obj);
    }
}