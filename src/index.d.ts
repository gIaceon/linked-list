interface list_item<T extends defined> {
	next?: list_item<T>;
	previous?: list_item<T>;
	item: T;
}

// eslint-disable-next-line @typescript-eslint/no-unsafe-declaration-merging
declare class linked_list<T extends defined> {
	public constructor(item?: T);
	static __iter: () => unknown;
	public head(): T | undefined;
	public tail(): T | undefined;
	public forEach(fn: (item: T) => void): void;
	public find(compare: (item: T) => boolean): T | undefined;
	public remove(item: T, destructor?: (item: T) => void, finder?: (item: T) => boolean): void;
	public clear(): void;
	public array(): T[];
	public add(item: T): () => void;
}
interface linked_list<T extends defined> extends IterableFunction<T> {}

export = linked_list;
