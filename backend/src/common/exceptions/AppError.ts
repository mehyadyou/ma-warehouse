export class AppError extends Error {
  public statusCode: number;
  public isOperational: boolean;
  public code?: string;
  public data?: unknown;

  constructor(message: string, statusCode: number = 400, code?: string, data?: unknown) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    this.code = code;
    this.data = data;
    Object.setPrototypeOf(this, AppError.prototype);
  }
}
