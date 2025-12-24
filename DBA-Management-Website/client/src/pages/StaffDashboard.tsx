import { StaffSidebar } from "@/components/StaffSidebar";
import { StatCard } from "@/components/StatCard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { BookOpen, Users, AlertCircle, UserPlus, TrendingUp, TrendingDown } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { ThemeToggle } from "@/components/ThemeToggle";
import { useAuth } from "@/lib/auth";
import { useState, useEffect } from "react";
import * as api from "@/lib/api";
import { Skeleton } from "@/components/ui/skeleton";
import { useLocation } from "wouter";

interface DashboardStats {
  total_checkouts_today?: number;
  total_returns_today?: number;
  overdue_count?: number;
  new_members_today?: number;
}

interface Alert {
  id: number;
  type: string;
  message: string;
  severity: 'high' | 'medium' | 'low';
}

interface Activity {
  action_type: string;
  patron_name: string;
  item_name: string;
  time_ago: string;
}

export default function StaffDashboard() {
  const { user } = useAuth();
  const [, setLocation] = useLocation();
  const [stats, setStats] = useState<DashboardStats>({});
  const [loading, setLoading] = useState(true);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const [recentActivity, setRecentActivity] = useState<Activity[]>([]);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    setLoading(true);
    try {
      // Load dashboard stats
      const statsResponse = await api.getDashboardOverview();
      setStats(statsResponse.data || {});

      // Load alerts
      const alertsResponse = await api.getDashboardAlerts();
      setAlerts(alertsResponse.data || []);

      // Load recent activity
      const activityResponse = await api.getRecentActivity();
      setRecentActivity(activityResponse.data || []);

    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex h-screen bg-background">
      <StaffSidebar />

      <div className="flex-1 flex flex-col overflow-hidden">
        <header className="border-b bg-background p-4 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold">Dashboard</h1>
            <p className="text-sm text-muted-foreground">
              Welcome back, {user?.username || 'Staff Member'}
            </p>
          </div>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="icon" onClick={() => setLocation('/')} title="Go to Home">
              <BookOpen className="h-5 w-5" />
            </Button>
            <ThemeToggle />
          </div>
        </header>

        <main className="flex-1 overflow-y-auto p-8">
          <div className="space-y-8">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {loading ? (
                <>
                  <Skeleton className="h-32" />
                  <Skeleton className="h-32" />
                  <Skeleton className="h-32" />
                  <Skeleton className="h-32" />
                </>
              ) : (
                <>
                  <StatCard
                    title="Today's Checkouts"
                    value={stats.total_checkouts_today || 0}
                    icon={BookOpen}
                    trend={{ value: 12, isPositive: true }}
                  />
                  <StatCard
                    title="Returns"
                    value={stats.total_returns_today || 0}
                    icon={TrendingDown}
                    trend={{ value: 5, isPositive: true }}
                  />
                  <StatCard
                    title="Overdue Items"
                    value={stats.overdue_count || 0}
                    icon={AlertCircle}
                    trend={{ value: 3, isPositive: false }}
                  />
                  <StatCard
                    title="New Members"
                    value={stats.new_members_today || 0}
                    icon={UserPlus}
                    trend={{ value: 15, isPositive: true }}
                  />
                </>
              )}
            </div>

            <div className="grid md:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle>Alerts & Notifications</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {loading ? (
                    <>
                      <Skeleton className="h-20" />
                      <Skeleton className="h-20" />
                    </>
                  ) : alerts.length > 0 ? (
                    alerts.map((alert) => (
                      <div
                        key={alert.id}
                        className={`p-4 rounded-md border ${alert.severity === 'high' ? 'border-destructive bg-destructive/10' :
                          alert.severity === 'medium' ? 'border-yellow-600 bg-yellow-600/10' :
                            'border-border bg-muted/50'
                          }`}
                        data-testid={`alert-${alert.id}`}
                      >
                        <div className="flex items-start justify-between gap-4">
                          <div className="flex items-start gap-3 flex-1">
                            <AlertCircle className={`h-5 w-5 mt-0.5 ${alert.severity === 'high' ? 'text-destructive' :
                              alert.severity === 'medium' ? 'text-yellow-600 dark:text-yellow-500' :
                                'text-muted-foreground'
                              }`} />
                            <p className="text-sm">{alert.message}</p>
                          </div>
                          <Button variant="ghost" size="sm" data-testid={`button-view-alert-${alert.id}`}>
                            View
                          </Button>
                        </div>
                      </div>
                    ))
                  ) : (
                    <p className="text-sm text-muted-foreground text-center py-4">
                      No alerts at this time
                    </p>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Recent Activity</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {loading ? (
                    <>
                      <Skeleton className="h-16" />
                      <Skeleton className="h-16" />
                      <Skeleton className="h-16" />
                    </>
                  ) : recentActivity.length > 0 ? (
                    recentActivity.map((activity, index) => (
                      <div key={index} className="flex items-center justify-between pb-4 border-b last:border-0 last:pb-0">
                        <div className="space-y-1">
                          <div className="flex items-center gap-2">
                            <Badge variant="secondary">{activity.action_type}</Badge>
                            <span className="font-medium text-sm">{activity.patron_name}</span>
                          </div>
                          <p className="text-sm text-muted-foreground">{activity.item_name}</p>
                        </div>
                        <span className="text-xs text-muted-foreground">{activity.time_ago}</span>
                      </div>
                    ))
                  ) : (
                    <p className="text-sm text-muted-foreground text-center py-4">
                      No recent activity
                    </p>
                  )}
                </CardContent>
              </Card>
            </div>

            <Card>
              <CardHeader>
                <CardTitle>Quick Actions</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <Button
                    variant="outline"
                    className="h-20 flex flex-col gap-2"
                    data-testid="button-quick-checkout"
                    onClick={() => setLocation('/staff/circulation')}
                  >
                    <BookOpen className="h-5 w-5" />
                    <span>Checkout</span>
                  </Button>
                  <Button
                    variant="outline"
                    className="h-20 flex flex-col gap-2"
                    data-testid="button-quick-return"
                    onClick={() => setLocation('/staff/circulation')}
                  >
                    <TrendingDown className="h-5 w-5" />
                    <span>Return</span>
                  </Button>
                  <Button
                    variant="outline"
                    className="h-20 flex flex-col gap-2"
                    data-testid="button-quick-register"
                    onClick={() => setLocation('/staff/patrons')}
                  >
                    <UserPlus className="h-5 w-5" />
                    <span>Register Patron</span>
                  </Button>
                  <Button
                    variant="outline"
                    className="h-20 flex flex-col gap-2"
                    data-testid="button-quick-search"
                    onClick={() => setLocation('/staff/patrons')}
                  >
                    <Users className="h-5 w-5" />
                    <span>Find Patron</span>
                  </Button>
                </div>
              </CardContent>
            </Card>
          </div>
        </main>
      </div>
    </div>
  );
}