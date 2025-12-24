import { StatCard } from '../StatCard';
import { BookOpen, Users, AlertCircle, UserPlus } from 'lucide-react';

export default function StatCardExample() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 p-8">
      <StatCard
        title="Active Loans"
        value={245}
        icon={BookOpen}
        trend={{ value: 12, isPositive: true }}
      />
      <StatCard
        title="Total Patrons"
        value="1,847"
        icon={Users}
        trend={{ value: 5, isPositive: true }}
      />
      <StatCard
        title="Overdue Items"
        value={18}
        icon={AlertCircle}
        trend={{ value: 3, isPositive: false }}
      />
      <StatCard
        title="New Members"
        value={32}
        icon={UserPlus}
        trend={{ value: 8, isPositive: true }}
      />
    </div>
  );
}