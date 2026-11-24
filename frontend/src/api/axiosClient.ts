import axios, { type AxiosError } from 'axios';
import type { ApiResponse } from '@/types/api';

const axiosClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api/v1',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

axiosClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiResponse<Record<string, string>>>) => {
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
