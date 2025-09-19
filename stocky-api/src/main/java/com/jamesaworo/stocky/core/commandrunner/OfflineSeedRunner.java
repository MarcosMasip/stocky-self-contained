package com.jamesaworo.stocky.core.commandrunner;

import com.jamesaworo.stocky.core.commandrunner.seeders.CompanySeeder;
import com.jamesaworo.stocky.core.commandrunner.seeders.PermissionSeeder;
import com.jamesaworo.stocky.core.commandrunner.seeders.SettingSeeder;
import com.jamesaworo.stocky.core.commandrunner.seeders.UserSeeder;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Ensures that when running the self-contained offline profile, base permissions,
 * roles, settings, company placeholder, and system user are present without manual actions.
 */
@Component
@Profile({"offline"})
@RequiredArgsConstructor
public class OfflineSeedRunner implements CommandLineRunner {

    private final PermissionSeeder permissionSeeder;
    private final UserSeeder userSeeder;
    private final CompanySeeder companySeeder;
    private final SettingSeeder settingSeeder;

    @Override
    public void run(String... args) {
        permissionSeeder.run();
        settingSeeder.run();
        companySeeder.run();
        userSeeder.run();
        System.out.println("[offline] Seed checks completed.");
    }
}
