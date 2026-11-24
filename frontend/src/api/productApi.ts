import axiosClient from '@/api/axiosClient';
import type { ApiResponse } from '@/types/api';
import type { Product, ProductPayload } from '@/types/product';

const RESOURCE_PATH = '/products';

export const productApi = {
  async getAll(keyword?: string): Promise<ApiResponse<Product[]>> {
    const params = keyword?.trim() ? { keyword: keyword.trim() } : undefined;
    const { data } = await axiosClient.get<ApiResponse<Product[]>>(RESOURCE_PATH, { params });
    return data;
  },

  async getById(id: number): Promise<ApiResponse<Product>> {
    const { data } = await axiosClient.get<ApiResponse<Product>>(`${RESOURCE_PATH}/${id}`);
    return data;
  },

  async create(payload: ProductPayload): Promise<ApiResponse<Product>> {
    const { data } = await axiosClient.post<ApiResponse<Product>>(RESOURCE_PATH, payload);
    return data;
  },

  async update(id: number, payload: ProductPayload): Promise<ApiResponse<Product>> {
    const { data } = await axiosClient.put<ApiResponse<Product>>(`${RESOURCE_PATH}/${id}`, payload);
    return data;
  },

  async remove(id: number): Promise<ApiResponse<void>> {
    const { data } = await axiosClient.delete<ApiResponse<void>>(`${RESOURCE_PATH}/${id}`);
    return data;
  },
};
