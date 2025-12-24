import { BookCard } from '../BookCard';

export default function BookCardExample() {
  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-6 p-8">
      <BookCard
        id={1}
        title="The Great Gatsby"
        author="F. Scott Fitzgerald"
        availability="available"
        genre="Classic"
        onClick={() => console.log('Book clicked: The Great Gatsby')}
      />
      <BookCard
        id={2}
        title="To Kill a Mockingbird"
        author="Harper Lee"
        availability="reserved"
        genre="Fiction"
      />
      <BookCard
        id={3}
        title="1984"
        author="George Orwell"
        availability="checked-out"
        genre="Dystopian"
      />
      <BookCard
        id={4}
        title="Pride and Prejudice"
        author="Jane Austen"
        availability="available"
        genre="Romance"
      />
    </div>
  );
}