import { ref } from 'vue';

export type NotificationType = 'success' | 'error';

export interface NotificationItem {
  id: number;
  type: NotificationType;
  message: string;
}

const notifications = ref<NotificationItem[]>([]);
let nextId = 1;

export function useNotification() {
  function dismiss(id: number): void {
    notifications.value = notifications.value.filter((item) => item.id !== id);
  }

  function push(type: NotificationType, message: string, durationMs = 3500): void {
    const id = nextId++;
    notifications.value.push({ id, type, message });

    if (durationMs > 0) {
      setTimeout(() => dismiss(id), durationMs);
    }
  }

  function notifySuccess(message: string): void {
    push('success', message);
  }

  function notifyError(message: string): void {
    push('error', message, 5000);
  }

  return {
    notifications,
    notifySuccess,
    notifyError,
    dismiss,
  };
}
