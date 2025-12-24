import { PatronHeader } from "@/components/PatronHeader";
import { StatisticsDashboard } from "@/components/ui/StatisticsDashboard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { LoanCard } from "@/components/LoanCard";
import { FineCard } from "@/components/FineCard";
import { Badge } from "@/components/ui/badge";
import { BookOpen, DollarSign, Clock, BookMarked } from "lucide-react";
import { useEffect, useState } from "react";
import * as api from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { useToast } from "@/hooks/use-toast";
import { useLocation } from "wouter";

interface PatronInfo {
  patron_id: number;
  full_name: string;
  email: string;
  phone: string;
  membership_type: string;
  account_status: string;
  total_fines_owed: number;
  current_loans: number;
  active_reservations: number;
  total_loans_history: number;
}

interface Loan {
  loan_id: number;
  title: string;
  author?: string;
  due_date: string;
  checkout_date: string;
  is_overdue?: boolean;
}

interface Fine {
  fine_id: number;
  title?: string;
  amount: number;
  reason?: string;
  dateIssued: string;
  status: "pending" | "paid" | "waived" | "unpaid";
}

interface Reservation {
  reservation_id: number;
  title?: string;
  author?: string;
  position: number;
  estimatedWait: string;
  reservation_status?: string;
}

export default function Account() {
  const { user } = useAuth();
  const { toast } = useToast();
  const [, setLocation] = useLocation();
  const [loading, setLoading] = useState(true);
  const [patronInfo, setPatronInfo] = useState<PatronInfo | null>(null);
  const [loans, setLoans] = useState<Loan[]>([]);
  const [fines, setFines] = useState<Fine[]>([]);
  const [reservations, setReservations] = useState<Reservation[]>([]);

  useEffect(() => {
    if (!user) {
      setLocation("/login");
      return;
    }
    loadAccountData();
  }, [user]);

  const loadAccountData = async () => {
    setLoading(true);
    try {
      const response = await api.getMyPatronDetails();
      const data = response.data;

      if (data.patron_info) {
        setPatronInfo(data.patron_info);
      }

      if (data.loans) {
        const mappedLoans: Loan[] = data.loans.map((loan: any) => ({
          loan_id: loan.loan_id,
          title: loan.title || loan.material_title || "Unknown Title",
          author: loan.author || "Unknown Author",
          due_date: loan.due_date,
          checkout_date: loan.checkout_date || loan.checkout_date,
          is_overdue: loan.is_overdue || false,
        }));
        setLoans(mappedLoans);
      }

      if (data.fines) {
        const mappedFines: Fine[] = data.fines.map((fine: any) => ({
          fine_id: fine.fine_id,
          title: fine.title || fine.material_title || "Unknown",
          amount: fine.amount || fine.fine_amount || 0,
          reason: fine.reason || fine.fine_reason || "Fine",
          dateIssued: fine.issue_date || fine.fine_date || new Date().toISOString(),
          status: (fine.status?.toLowerCase() || "pending") as
            | "pending"
            | "paid"
            | "waived"
            | "unpaid",
        }));
        setFines(mappedFines);
      }

      if (data.reservations) {
        const mappedReservations: Reservation[] = data.reservations.map(
          (res: any) => ({
            reservation_id: res.reservation_id,
            title: res.title || res.material_title || "Unknown Title",
            author: res.author || "Unknown Author",
            position: res.position || res.queue_position || 0,
            estimatedWait:
              res.estimated_wait ||
              (res.reservation_status === "Ready"
                ? "Ready for pickup!"
                : "Waiting..."),
            reservation_status: res.reservation_status,
          })
        );
        setReservations(mappedReservations);
      }
    } catch (error: any) {
      console.error("Failed to load account data:", error);
      toast({
        title: "Error",
        description:
          error.response?.data?.detail ||
          "Failed to load account information",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const totalFines = fines
    .filter((f) => f.status === "pending" || f.status === "unpaid")
    .reduce((acc, f) => acc + (f.amount || 0), 0);

  const activeLoansCount = loans.length;
  const reservationsCount = reservations.length;
  const booksReadCount = patronInfo?.total_loans_history || 0;

  return (
    <div className="min-h-screen bg-background">
      <PatronHeader />

      <div className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-2">My Account</h1>
          <p className="text-muted-foreground">
            {patronInfo
              ? `Welcome, ${patronInfo.full_name}`
              : "Manage your loans, reservations, and fines"}
          </p>
        </div>

        {loading ? (
          <div className="text-center py-12">
            <p className="text-muted-foreground">
              Loading account information...
            </p>
          </div>
        ) : (
          <>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center gap-4">
                    <div className="h-12 w-12 rounded-md bg-primary/10 flex items-center justify-center">
                      <BookOpen className="h-6 w-6 text-primary" />
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">
                        Active Loans
                      </p>
                      <p className="text-2xl font-bold">{activeLoansCount}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center gap-4">
                    <div className="h-12 w-12 rounded-md bg-yellow-600/10 dark:bg-yellow-700/10 flex items-center justify-center">
                      <DollarSign className="h-6 w-6 text-yellow-600 dark:text-yellow-500" />
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">
                        Fines Owed
                      </p>
                      <p className="text-2xl font-bold">
                        ${totalFines.toFixed(2)}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center gap-4">
                    <div className="h-12 w-12 rounded-md bg-primary/10 flex items-center justify-center">
                      <Clock className="h-6 w-6 text-primary" />
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">
                        Reservations
                      </p>
                      <p className="text-2xl font-bold">
                        {reservationsCount}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center gap-4">
                    <div className="h-12 w-12 rounded-md bg-primary/10 flex items-center justify-center">
                      <BookMarked className="h-6 w-6 text-primary" />
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">
                        Books Read
                      </p>
                      <p className="text-2xl font-bold">{booksReadCount}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>

            <Tabs defaultValue="loans" className="space-y-6">
              <TabsList>
                <TabsTrigger value="loans" data-testid="tab-loans">
                  Current Loans
                </TabsTrigger>
                <TabsTrigger
                  value="reservations"
                  data-testid="tab-reservations"
                >
                  Reservations
                </TabsTrigger>
                <TabsTrigger value="fines" data-testid="tab-fines">
                  Fines
                </TabsTrigger>
                <TabsTrigger value="history" data-testid="tab-history">
                  History
                </TabsTrigger>
              </TabsList>

              <TabsContent value="loans" className="space-y-4">
                {loans.length > 0 ? (
                  loans.map((loan) => (
                    <LoanCard
                      key={loan.loan_id}
                      id={loan.loan_id}
                      bookTitle={loan.title}
                      author={loan.author || "Unknown Author"}
                      dueDate={new Date(loan.due_date)}
                      checkedOutDate={new Date(loan.checkout_date)}
                      canRenew={!loan.is_overdue}
                    />
                  ))
                ) : (
                  <Card>
                    <CardContent className="p-6 text-center text-muted-foreground">
                      No active loans at this time.
                    </CardContent>
                  </Card>
                )}
              </TabsContent>

              <TabsContent value="reservations" className="space-y-4">
                {reservations.length > 0 ? (
                  reservations.map((reservation) => (
                    <Card
                      key={reservation.reservation_id}
                      data-testid={`card-reservation-${reservation.reservation_id}`}
                    >
                      <CardContent className="p-6">
                        <div className="flex items-start justify-between">
                          <div className="space-y-1 flex-1">
                            <h3 className="font-semibold">
                              {reservation.title}
                            </h3>
                            <p className="text-sm text-muted-foreground">
                              {reservation.author}
                            </p>
                            <div className="flex items-center gap-2 mt-2">
                              <Badge
                                variant={
                                  reservation.reservation_status === "Ready"
                                    ? "default"
                                    : "secondary"
                                }
                              >
                                {reservation.reservation_status === "Ready"
                                  ? "Ready"
                                  : `Position: ${reservation.position || 0}`}
                              </Badge>
                              <span className="text-sm text-muted-foreground">
                                {reservation.estimatedWait}
                              </span>
                            </div>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))
                ) : (
                  <Card>
                    <CardContent className="p-6 text-center text-muted-foreground">
                      No active reservations.
                    </CardContent>
                  </Card>
                )}
              </TabsContent>

              <TabsContent value="fines" className="space-y-4">
                {fines.length > 0 ? (
                  fines.map((fine) => (
                    <FineCard
                      key={fine.fine_id}
                      id={fine.fine_id}
                      bookTitle={fine.title || "Unknown"}
                      amount={fine.amount}
                      reason={fine.reason || "Fine"}
                      dateIssued={new Date(fine.dateIssued)}
                      status={fine.status}
                    />
                  ))
                ) : (
                  <Card>
                    <CardContent className="p-6 text-center text-muted-foreground">
                      No fines at this time.
                    </CardContent>
                  </Card>
                )}
              </TabsContent>

              <TabsContent value="history">
                <Card>
                  <CardHeader>
                    <CardTitle>Reading History</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-muted-foreground">
                      {booksReadCount > 0
                        ? `You have borrowed ${booksReadCount} book${
                            booksReadCount !== 1 ? "s" : ""
                          } in total.`
                        : "Your complete borrowing history will appear here"}
                    </p>
                  </CardContent>
                </Card>
              </TabsContent>

              <StatisticsDashboard />
            </Tabs>
          </>
        )}
      </div>
    </div>
  );
}
