import { FineCard } from '../FineCard';

export default function FineCardExample() {
  const today = new Date();
  const lastWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
  const lastMonth = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000);

  return (
    <div className="max-w-2xl mx-auto p-8 space-y-6">
      <FineCard
        id={1}
        bookTitle="The Great Gatsby"
        amount={5.50}
        reason="Late return (5 days)"
        dateIssued={lastWeek}
        status="pending"
        onPay={() => console.log('Payment initiated')}
      />
      <FineCard
        id={2}
        bookTitle="1984"
        amount={3.00}
        reason="Late return (3 days)"
        dateIssued={lastMonth}
        status="paid"
      />
      <FineCard
        id={3}
        bookTitle="To Kill a Mockingbird"
        amount={2.00}
        reason="Late return (2 days)"
        dateIssued={lastMonth}
        status="waived"
      />
    </div>
  );
}