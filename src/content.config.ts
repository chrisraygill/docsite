import { defineCollection, z } from 'astro:content';
import { docsLoader } from '@astrojs/starlight/loaders';
import { docsSchema } from '@astrojs/starlight/schema';

const description = z
	.union([
		z.string(),
		z
			.object({
				default: z.string().optional(),
				js: z.string().optional(),
				go: z.string().optional(),
				dart: z.string().optional(),
				python: z.string().optional(),
			})
			.transform((value) => value.default),
	])
	.optional();

export const collections = {
	docs: defineCollection({
		loader: docsLoader(),
		schema: (context) => {
			const starlightBase = docsSchema()(context) as unknown as z.AnyZodObject;
			return starlightBase.omit({ description: true }).extend({
				description,
				supportedLanguages: z.array(z.enum(['js', 'go', 'dart', 'python'])).default(['js', 'go', 'dart', 'python']),
				isLanguageAgnostic: z.boolean().optional(),
			});
		},
	}),
};
