import { StaffSidebar } from "@/components/StaffSidebar";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/ThemeToggle";
import { FileText, Home, CheckCircle, XCircle } from "lucide-react";
import { useState, useEffect } from "react";
import * as api from "@/lib/api";
import { useToast } from "@/hooks/use-toast";
import { getUserId } from "@/lib/auth-utils";
import { useLocation } from "wouter";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export default function Reservations() {
    const { toast } = useToast();
    const staffId = getUserId();
    const [, setLocation] = useLocation();
    const [reservations, setReservations] = useState<any[]>([]);
    const [loading, setLoading] = useState(false);
    const [activeTab, setActiveTab] = useState('all');

    // Fulfill reservation state
    const [fulfillReservationId, setFulfillReservationId] = useState('');
    const [fulfillCopyId, setFulfillCopyId] = useState('');
    const [fulfilling, setFulfilling] = useState(false);

    useEffect(() => {
        loadReservations();
    }, [activeTab]);

    const loadReservations = async () => {
        setLoading(true);
        try {
            const status = activeTab === 'all' ? undefined : activeTab;
            const response = await api.getActiveReservations(status);
            setReservations(response.data?.reservations || []);
        } catch (error: any) {
            toast({
                title: "Error",
                description: error.response?.data?.detail || "Failed to load reservations",
                variant: "destructive",
            });
        } finally {
            setLoading(false);
        }
    };

    const handleFulfill = async (e: React.FormEvent) => {
        e.preventDefault();
        setFulfilling(true);

        try {
            await api.fulfillReservation(
                parseInt(fulfillReservationId),
                parseInt(fulfillCopyId),
                staffId
            );
            toast({
                title: "Reservation Fulfilled",
                description: "Reservation has been fulfilled successfully",
            });
            setFulfillReservationId('');
            setFulfillCopyId('');
            loadReservations();
        } catch (error: any) {
            toast({
                title: "Error",
                description: error.response?.data?.detail || "Failed to fulfill reservation",
                variant: "destructive",
            });
        } finally {
            setFulfilling(false);
        }
    };

    const handleCancel = async (reservationId: number, patronId: number) => {
        try {
            await api.cancelReservation(reservationId, patronId);
            toast({
                title: "Reservation Cancelled",
                description: "Reservation has been cancelled successfully",
            });
            loadReservations();
        } catch (error: any) {
            toast({
                title: "Error",
                description: error.response?.data?.detail || "Failed to cancel reservation",
                variant: "destructive",
            });
        }
    };

    const getStatusBadge = (status: string) => {
        const variants: Record<string, "default" | "secondary" | "destructive" | "outline"> = {
            'Pending': 'secondary',
            'Ready': 'default',
            'Expired': 'destructive',
            'Cancelled': 'outline'
        };
        return <Badge variant={variants[status] || 'default'}>{status}</Badge>;
    };

    return (
        <div className="flex h-screen bg-background">
            <StaffSidebar />

            <div className="flex-1 flex flex-col overflow-hidden">
                <header className="border-b bg-background p-4 flex items-center justify-between">
                    <div>
                        <h1 className="text-2xl font-bold">Reservations</h1>
                        <p className="text-sm text-muted-foreground">Manage material reservations</p>
                    </div>
                    <div className="flex items-center gap-2">
                        <Button variant="outline" size="icon" onClick={() => setLocation('/')} title="Go to Home">
                            <Home className="h-5 w-5" />
                        </Button>
                        <ThemeToggle />
                    </div>
                </header>

                <main className="flex-1 overflow-y-auto p-8">
                    <div className="space-y-6">
                        <Card>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2">
                                    <FileText className="h-5 w-5" />
                                    Active Reservations
                                </CardTitle>
                                <CardDescription>
                                    View and manage patron reservations
                                </CardDescription>
                            </CardHeader>
                            <CardContent>
                                <Tabs value={activeTab} onValueChange={setActiveTab}>
                                    <TabsList>
                                        <TabsTrigger value="all">All</TabsTrigger>
                                        <TabsTrigger value="Pending">Pending</TabsTrigger>
                                        <TabsTrigger value="Ready">Ready</TabsTrigger>
                                        <TabsTrigger value="Expired">Expired</TabsTrigger>
                                    </TabsList>

                                    <TabsContent value={activeTab} className="mt-4">
                                        {loading ? (
                                            <p className="text-sm text-muted-foreground text-center py-8">Loading...</p>
                                        ) : reservations.length > 0 ? (
                                            <div className="border rounded-lg">
                                                <Table>
                                                    <TableHeader>
                                                        <TableRow>
                                                            <TableHead>ID</TableHead>
                                                            <TableHead>Patron</TableHead>
                                                            <TableHead>Material</TableHead>
                                                            <TableHead>Status</TableHead>
                                                            <TableHead>Date</TableHead>
                                                            <TableHead>Queue</TableHead>
                                                            <TableHead>Actions</TableHead>
                                                        </TableRow>
                                                    </TableHeader>
                                                    <TableBody>
                                                        {reservations.map((reservation) => (
                                                            <TableRow key={reservation.reservation_id}>
                                                                <TableCell>{reservation.reservation_id}</TableCell>
                                                                <TableCell>
                                                                    <div>
                                                                        <p className="font-medium">{reservation.patron_name}</p>
                                                                        <p className="text-xs text-muted-foreground">{reservation.patron_email}</p>
                                                                    </div>
                                                                </TableCell>
                                                                <TableCell>
                                                                    <div>
                                                                        <p className="font-medium">{reservation.material_title}</p>
                                                                        <p className="text-xs text-muted-foreground">{reservation.material_type}</p>
                                                                    </div>
                                                                </TableCell>
                                                                <TableCell>{getStatusBadge(reservation.reservation_status)}</TableCell>
                                                                <TableCell className="text-sm">{reservation.reservation_date}</TableCell>
                                                                <TableCell>{reservation.queue_position || 'N/A'}</TableCell>
                                                                <TableCell>
                                                                    <div className="flex gap-2">
                                                                        <Button
                                                                            size="sm"
                                                                            variant="outline"
                                                                            onClick={() => {
                                                                                setFulfillReservationId(reservation.reservation_id.toString());
                                                                            }}
                                                                        >
                                                                            <CheckCircle className="h-4 w-4" />
                                                                        </Button>
                                                                        <Button
                                                                            size="sm"
                                                                            variant="destructive"
                                                                            onClick={() => handleCancel(reservation.reservation_id, reservation.patron_id)}
                                                                        >
                                                                            <XCircle className="h-4 w-4" />
                                                                        </Button>
                                                                    </div>
                                                                </TableCell>
                                                            </TableRow>
                                                        ))}
                                                    </TableBody>
                                                </Table>
                                            </div>
                                        ) : (
                                            <p className="text-sm text-muted-foreground text-center py-8">
                                                No reservations found
                                            </p>
                                        )}
                                    </TabsContent>
                                </Tabs>
                            </CardContent>
                        </Card>

                        <Card>
                            <CardHeader>
                                <CardTitle>Fulfill Reservation</CardTitle>
                                <CardDescription>Mark a reservation as ready for pickup</CardDescription>
                            </CardHeader>
                            <CardContent>
                                <form onSubmit={handleFulfill} className="space-y-4">
                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="space-y-2">
                                            <Label htmlFor="reservation-id">Reservation ID</Label>
                                            <Input
                                                id="reservation-id"
                                                type="number"
                                                placeholder="Enter reservation ID"
                                                value={fulfillReservationId}
                                                onChange={(e) => setFulfillReservationId(e.target.value)}
                                                required
                                                disabled={fulfilling}
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <Label htmlFor="copy-id">Copy ID</Label>
                                            <Input
                                                id="copy-id"
                                                type="number"
                                                placeholder="Enter copy ID"
                                                value={fulfillCopyId}
                                                onChange={(e) => setFulfillCopyId(e.target.value)}
                                                required
                                                disabled={fulfilling}
                                            />
                                        </div>
                                    </div>
                                    <Button type="submit" disabled={fulfilling} className="w-full">
                                        <CheckCircle className="mr-2 h-4 w-4" />
                                        {fulfilling ? 'Fulfilling...' : 'Fulfill Reservation'}
                                    </Button>
                                </form>
                            </CardContent>
                        </Card>
                    </div>
                </main>
            </div>
        </div>
    );
}
