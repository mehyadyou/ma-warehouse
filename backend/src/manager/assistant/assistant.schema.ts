import { z } from 'zod';

export const chatHistoryItemSchema = z.object({
    role:    z.enum(['user', 'assistant']),
    content: z.string().trim().min(1, 'متن پیام خالی است').max(4000, 'متن پیام حداکثر ۴۰۰۰ نویسه است'),
});

export const assistantChatSchema = z.object({
    message: z.string('پیام الزامی است').trim().min(1, 'پیام الزامی است').max(2000, 'پیام حداکثر ۲۰۰۰ نویسه است'),
    history: z.array(chatHistoryItemSchema).max(12, 'تاریخچه حداکثر ۱۲ پیام است').default([]),
});

export type AssistantChatInput = z.infer<typeof assistantChatSchema>;
export type ChatHistoryItem = z.infer<typeof chatHistoryItemSchema>;