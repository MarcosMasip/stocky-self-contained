import {InjectionToken} from '@angular/core';

import Rollbar from 'rollbar';
import {environment} from 'src/environments/environment';

// Telemetry & error reporting disabled by default in offline fork.
const telemetryEnabled = (window as any)['ENABLE_TELEMETRY'] === true && environment.production;
const rollbarConfig: Rollbar.Configuration = {
    accessToken: telemetryEnabled ? 'b209d23d8c4b459086e4869af05271fe' : 'disabled-token',
    captureUncaught: telemetryEnabled,
    captureUnhandledRejections: telemetryEnabled,
    captureEmail: telemetryEnabled,
    captureIp: telemetryEnabled,
    captureUsername: telemetryEnabled,
    environment: telemetryEnabled ? (environment.production ? 'production' : 'development') : 'offline',
    enabled: telemetryEnabled,
    ignoredMessages: ['Script error.']
};

export function rollbarFactory() {
    return new Rollbar(rollbarConfig);
}

export const RollbarService = new InjectionToken<Rollbar>('rollbar');
