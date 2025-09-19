import * as amplitude from '@amplitude/analytics-browser';
import {Injectable} from '@angular/core';
import {environment} from '@env/environment';


@Injectable({
    providedIn: 'root'
})
@Injectable()
export class AmplitudeService {
    
    constructor() {
        // Telemetry disabled by default for offline self-contained fork.
        // Enable by setting window['ENABLE_TELEMETRY']=true before app bootstrap or building with a custom env.
        const enabled = (window as any)['ENABLE_TELEMETRY'] === true && environment.production;
        if (enabled) {
            amplitude.init('90b7a2838a65c40db5f66fa20fcc2737');
        }
    }
}
