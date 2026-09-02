import { z } from 'zod';

/// تیک زدن/برداشتن تیک راننده — اتصال/قطع راننده به انبارِ خودِ انباردار
export const assignDriverSchema = z.object({
    assigned: z.boolean(),
});

export type AssignDriverInput = z.infer<typeof assignDriverSchema>;