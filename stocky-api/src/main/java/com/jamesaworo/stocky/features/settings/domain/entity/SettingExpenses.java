package com.jamesaworo.stocky.features.settings.domain.entity;


import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import static com.jamesaworo.stocky.core.constants.Table.SETTING_EXPENSES;

@Entity
@Table(name = SETTING_EXPENSES)
public class SettingExpenses extends Setting {

    public SettingExpenses() {
    }

    public SettingExpenses(SettingObj obj) {
        super(obj);
    }
}