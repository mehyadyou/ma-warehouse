import { Request, Response } from 'express';
import { asyncHandler } from '../../middleware/asyncHandler';
import { AssistantChatInput } from './assistant.schema';
import { assistantService } from './assistant.service';

export const assistantController = {
    /** پاسخ کامل (بدون استریم) — fallback وقتی سوکت در دسترس نیست */
    chat: asyncHandler(async (req: Request, res: Response) => {
        const body = req.body as AssistantChatInput;
        const { answer } = await assistantService.chat({
            message: body.message,
            history: body.history ?? [],
        });
        res.json({ answer });
    }),

    /**
     * استریم Server-Sent Events — برای وقتی سوکت وصل نیست.
     * هر رویداد یک خط `data: {json}` است: {type:'status'} | {type:'token'} | {type:'done'} | {type:'error'}
     */
    chatStream: async (req: Request, res: Response) => {
        const body = req.body as AssistantChatInput;

        res.setHeader('Content-Type', 'text/event-stream; charset=utf-8');
        res.setHeader('Cache-Control', 'no-cache, no-transform');
        res.setHeader('Connection', 'keep-alive');
        res.setHeader('X-Accel-Buffering', 'no');
        res.flushHeaders();

        const send = (type: string, payload: Record<string, unknown>) => {
            if (res.writableEnded) return;
            res.write(`data: ${JSON.stringify({ type, ...payload })}\n\n`);
        };

        // قطع شدن کلاینت → توقف تولید توکن در سمت مدل
        const ac = new AbortController();
        req.on('close', () => ac.abort());

        try {
            const { answer } = await assistantService.chatStream(
                { message: body.message, history: body.history ?? [] },
                {
                    onToken: (text) => send('token', { text }),
                    onStatus: (text) => send('status', { text }),
                    signal: ac.signal,
                },
            );
            send('done', { fullText: answer });
        } catch (e) {
            send('error', { error: (e as Error)?.message ?? 'خطای داخلی دستیار' });
        } finally {
            res.end();
        }
    },
};
