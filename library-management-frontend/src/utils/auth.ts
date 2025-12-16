export const setAuthToken = (token: string) => {
  localStorage.setItem('session_id', token);
};

export const getAuthToken = (): string | null => {
  return localStorage.getItem('session_id');
};

export const removeAuthToken = () => {
  localStorage.removeItem('session_id');
};

export const getUserId = (): number => {
  return parseInt(localStorage.getItem('user_id') || '0');
};

export const setUserId = (userId: number) => {
  localStorage.setItem('user_id', userId.toString());
};
