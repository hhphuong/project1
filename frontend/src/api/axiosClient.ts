import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import type { ApiResponse } from '@/types/api';

const TOKEN_STORAGE_KEY = 'accessToken';

const axiosClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api/v1',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

axiosClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem(TOKEN_STORAGE_KEY);
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error),
);

axiosClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiResponse<Record<string, string>>>) => {
    if (error.response?.status === 401) {
      const requestUrl = error.config?.url ?? '';
      if (!requestUrl.includes('/auth/login')) {
        localStorage.removeItem(TOKEN_STORAGE_KEY);
        if (window.location.pathname !== '/login') {
          window.location.href = '/login';
        }
      }
    }

    const serverMessage = error.response?.data?.message;
    const validationErrors = error.response?.data?.data;

    if (validationErrors && typeof validationErrors === 'object') {
      const details = Object.values(validationErrors).join('; ');
      return Promise.reject(new Error(details || serverMessage || 'Validation failed'));
    }

    const message = serverMessage || error.message || 'An unexpected error occurred';
    return Promise.reject(new Error(message));
  },
);

export default axiosClient;