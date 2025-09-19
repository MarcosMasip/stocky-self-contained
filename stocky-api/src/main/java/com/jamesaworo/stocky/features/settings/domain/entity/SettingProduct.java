package com.jamesaworo.stocky.features.settings.domain.entity;


import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import static com.jamesaworo.stocky.core.constants.Table.SETTING_PRODUCT;

@Entity
@Table(name = SETTING_PRODUCT)
public class SettingProduct extends Setting {

    public SettingProduct() {
    }

    public SettingProduct(SettingObj obj) {
        super(obj);
    }
}