import { LoanCard } from '../LoanCard';

export default function LoanCardExample() {
  const today = new Date();
  const inTwoDays = new Date(today.getTime() + 2 * 24 * 60 * 60 * 1000);
  const inTwoWeeks = new Date(today.getTime() + 14 * 24 * 60 * 60 * 1000);
  const yesterday = new Date(today.getTime() - 1 * 24 * 60 * 60 * 1000);
  const twoWeeksAgo = new Date(today.getTime() - 14 * 24 * 60 * 60 * 1000);

  return (
    <div className="max-w-2xl mx-auto p-8 space-y-6">
      <LoanCard
        id={1}
        bookTitle="The Great Gatsby"
        author="F. Scott Fitzgerald"
        dueDate={inTwoDays}
        checkedOutDate={twoWeeksAgo}
        onRenew={() => console.log('Renewed')}
      />
      <LoanCard
        id={2}
        bookTitle="1984"
        author="George Orwell"
        dueDate={inTwoWeeks}
        checkedOutDate={today}
      />
      <LoanCard
        id={3}
        bookTitle="To Kill a Mockingbird"
        author="Harper Lee"
        dueDate={yesterday}
        checkedOutDate={twoWeeksAgo}
        canRenew={false}
      />
    </div>
  );
}