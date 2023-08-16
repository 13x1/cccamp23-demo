import { getI18nStores } from '../i18n/i18n.js';
import type { LayoutLoad } from './$types';

export const load: LayoutLoad = async ({ data }) => {
    return {
        ...(await getI18nStores(data.requestLocale))
    };
};

export const ssr = false
