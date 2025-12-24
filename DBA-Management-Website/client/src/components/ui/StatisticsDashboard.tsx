import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { 
  BookOpen, 
  Clock, 
  AlertTriangle, 
  CheckCircle,
  TrendingUp,
  Calendar,
  DollarSign,
  Star,
  Award,
  BookMarked
} from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { useState } from "react";
import * as api from "@/lib/api";

interface StatisticsData {
  overview: any;
  active_loans: any[];
  loan_history: any[];
  reservations: any[];
  fines: any[];
  recommended: any[];
}

export function StatisticsDashboard() {
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);
  const [stats, setStats] = useState<StatisticsData | null>(null);

  const loadStatistics = async () => {
    setLoading(true);
    try {
      const response = await api.getPatronStatistics();
      setStats(response.data);
      toast({
        title: "Statistics Loaded",
        description: "Your library activity has been analyzed",
      });
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.response?.data?.detail || "Failed to load statistics",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  if (!stats) {
    return (
      <Card className="mt-6">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <TrendingUp className="h-5 w-5" />
            Your Library Statistics
          </CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground mb-4">
            View detailed insights about your reading habits, borrowing patterns, and library activity.
          </p>
          <Button onClick={loadStatistics} disabled={loading}>
            {loading ? "Loading..." : "View My Statistics"}
          </Button>
        </CardContent>
      </Card>
    );
  }

  const { overview, active_loans, loan_history, reservations, fines, recommended } = stats;

  return (
    <div className="space-y-6 mt-6">
      {/* Account Health Banner */}
      <Card className={`border-2 ${
        overview.account_health_status === 'GOOD' 
          ? 'border-green-500 bg-green-50 dark:bg-green-950' 
          : 'border-yellow-500 bg-yellow-50 dark:bg-yellow-950'
      }`}>
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              {overview.account_health_status === 'GOOD' ? (
                <CheckCircle className="h-8 w-8 text-green-600" />
              ) : (
                <AlertTriangle className="h-8 w-8 text-yellow-600" />
              )}
              <div>
                <h3 className="text-xl font-bold">
                  Account Status: {overview.account_health_status === 'GOOD' ? 'Excellent' : 'Needs Attention'}
                </h3>
                <p className="text-sm text-muted-foreground">
                  Membership: {overview.membership_type} • 
                  {overview.membership_status_flag === 'EXPIRED' && ' EXPIRED'}
                  {overview.membership_status_flag === 'EXPIRING_SOON' && ` Expires in ${overview.days_until_expiry} days`}
                  {overview.membership_status_flag === 'ACTIVE' && ' Active'}
                </p>
              </div>
            </div>
            <Button variant="outline" onClick={() => setStats(null)}>
              Refresh
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Quick Stats Grid */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <BookOpen className="h-8 w-8 text-blue-500" />
              <div>
                <p className="text-xs text-muted-foreground">Available Slots</p>
                <p className="text-2xl font-bold">{overview.loans_remaining}</p>
                <p className="text-xs text-muted-foreground">of {overview.max_borrow_limit}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <Award className="h-8 w-8 text-purple-500" />
              <div>
                <p className="text-xs text-muted-foreground">Total Borrowed</p>
                <p className="text-2xl font-bold">{overview.total_loans_ever}</p>
                <p className="text-xs text-muted-foreground">all time</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <Calendar className="h-8 w-8 text-orange-500" />
              <div>
                <p className="text-xs text-muted-foreground">This Month</p>
                <p className="text-2xl font-bold">{overview.loans_this_month}</p>
                <p className="text-xs text-muted-foreground">borrowed</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <DollarSign className="h-8 w-8 text-red-500" />
              <div>
                <p className="text-xs text-muted-foreground">Fines Owed</p>
                <p className="text-2xl font-bold">${overview.total_fines_owed}</p>
                <p className="text-xs text-muted-foreground">{overview.unpaid_fines_count} unpaid</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Active Loans Detailed */}
      {active_loans.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Active Loans Breakdown</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {active_loans.map((loan) => (
              <div 
                key={loan.loan_id} 
                className={`p-4 rounded-lg border ${
                  loan.status_flag === 'OVERDUE' ? 'border-red-500 bg-red-50 dark:bg-red-950' :
                  loan.status_flag === 'DUE_SOON' ? 'border-yellow-500 bg-yellow-50 dark:bg-yellow-950' :
                  'border-gray-200'
                }`}
              >
                <div className="flex justify-between items-start">
                  <div>
                    <h4 className="font-semibold">{loan.title}</h4>
                    <p className="text-sm text-muted-foreground">{loan.author_name}</p>
                    <div className="flex gap-2 mt-2">
                      <Badge variant={loan.status_flag === 'OVERDUE' ? 'destructive' : 'secondary'}>
                        {loan.status_flag === 'OVERDUE' && `${loan.days_overdue} days overdue`}
                        {loan.status_flag === 'DUE_TODAY' && 'Due today'}
                        {loan.status_flag === 'DUE_SOON' && `Due in ${loan.days_remaining} days`}
                        {loan.status_flag === 'NORMAL' && `${loan.days_remaining} days left`}
                      </Badge>
                      <Badge variant="outline">{loan.renewal_status.replace(/_/g, ' ')}</Badge>
                    </div>
                  </div>
                  {loan.potential_fine > 0 && (
                    <div className="text-right">
                      <p className="text-sm text-muted-foreground">Potential fine</p>
                      <p className="text-lg font-bold text-red-600">${loan.potential_fine}</p>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      )}

      {/* Recommended Books */}
      {recommended.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Star className="h-5 w-5 text-yellow-500" />
              Recommended for You
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {recommended.slice(0, 6).map((book) => (
                <div key={book.material_id} className="p-4 border rounded-lg hover:bg-accent/50 transition-colors">
                  <div className="flex justify-between items-start">
                    <div className="flex-1">
                      <h4 className="font-semibold line-clamp-1">{book.title}</h4>
                      <p className="text-sm text-muted-foreground">{book.author_name}</p>
                      <div className="flex gap-2 mt-2">
                        <Badge variant="secondary">{book.primary_genre}</Badge>
                        <Badge variant={book.availability_status === 'AVAILABLE' ? 'default' : 'outline'}>
                          {book.availability_status === 'AVAILABLE' ? 'Available' : 'Checked out'}
                        </Badge>
                      </div>
                    </div>
                    <div className="text-right text-sm">
                      <p className="text-muted-foreground">Popular</p>
                      <p className="font-semibold">{book.recent_checkouts} loans</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Reading Activity Summary */}
      <Card>
        <CardHeader>
          <CardTitle>Reading Activity</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-sm text-muted-foreground">Returns this month</p>
              <p className="text-2xl font-bold">{overview.returns_this_month}</p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">On-time returns</p>
              <p className="text-2xl font-bold">{overview.total_returns}</p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Pending reservations</p>
              <p className="text-2xl font-bold">{overview.pending_reservations_count}</p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Ready to pickup</p>
              <p className="text-2xl font-bold text-green-600">{overview.ready_reservations_count}</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}