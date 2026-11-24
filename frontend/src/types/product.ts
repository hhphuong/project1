export interface Product {
  id: number;
  name: string;
  description: string | null;
  price: number;
  quantity: number;
  active: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface ProductPayload {
  name: string;
  description: string;
  price: number;
  quantity: number;
  active: boolean;
}
