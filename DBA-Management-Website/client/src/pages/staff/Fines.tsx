import { StaffSidebar } from "@/components/StaffSidebar";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ThemeToggle } from "@/components/ThemeToggle";
import { DollarSign, CreditCard, Ban, Home, AlertCircle } from "lucide-react";
import { useState, useEffect } from "react";
import * as api from "@/lib/api";
import { useToast } from "@/hooks/use-toast";
import { getUserId } from "@/lib/auth-utils";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useLocation } from "wouter";

export default function Fines() {
    const { toast } = useToast();
    const staffId = getUserId();
    const [, setLocation] = useLocation();

    const [fineId, setFineId] = useState('');
    const [paymentAmount, setPaymentAmount] = useState('');
    const [waiveReason, setWaiveReason] = useState('');
    const [loading, setLoading] = useState(false);

    // Fines list state
    const [fines, setFines] = useState<any[]>([]);
    const [finesLoading, setFinesLoading] = useState(false);
    const [statusFilter, setStatusFilter] = useState('all');

    // Assess fine state
    const [assessForm, setAssessForm] = useState({
        patron_id: '',
        loan_id: '',
        fine_type: 'Overdue',
        amount: '',
    });
    const [assessing, setAssessing] = useState(false);

    useEffect(() => {
        loadFines();
    }, [statusFilter]);

    const loadFines = async () => {
        setFinesLoading(true);
        try {
            const status = statusFilter === 'all' ? undefined : statusFilter;
            const response = await api.getAllFines(status);
            setFines(response.data?.fines || []);
        } catch (error: any) {
            toast({
                title: "Error",
                description: error.response?.data?.detail || "Failed to load fines",
                variant: "destructive",
            });
        } finally {
            setFinesLoading(false);
        }
    };

    const handlePayFine = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            await api.payFine({
                fine_id: parseInt(fineId),
                payment_amount: parseFloat(paymentAmount),
                payment_method: 'Cash',
                staff_id: staffId
            });

            toast({
                title: "Payment Processed",
                description: "Fine payment has been recorded",
            });

            setFineId('');
            setPaymentAmount('');
            loadFines();
        } catch (error: any) {
            toast({
                title: "Payment Failed",
                description: error.response?.data?.detail || "An error occurred",
                variant: "destructive",
            });
        } finally {
            setLoading(false);
        }
    };

    const handleWaiveFine = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            await api.waiveFine({
                fine_id: parseInt(fineId),
                waiver_reason: waiveReason,
                staff_id: staffId
            });

            toast({
                title: "Fine Waived",
                description: "Fine has been waived successfully",
            });

            setFineId('');
            setWaiveReason('');
            loadFines();
        } catch (error: any) {
            toast({
                title: "Waive Failed",
                description: error.response?.data?.detail || "An error occurred",
                variant: "destructive",
            });
        } finally {
            setLoading(false);
        }
    };

    const handleAssessFine = async (e: React.FormEvent) => {
        e.preventDefault();
        setAssessing(true);

        try {
            await api.assessFine({
                patron_id: parseInt(assessForm.patron_id),
                loan_id: assessForm.loan_id ? parseInt(assessForm.loan_id) : null,
                fine_type: assessForm.fine_type,
                amount: parseFloat(assessForm.amount),
                staff_id: staffId
            });

            toast({
                title: "Fine Assessed",
                description: "Fine has been assessed successfully",
            });

            setAssessForm({
                patron_id: '',
                loan_id: '',
                fine_type: 'Overdue',
                amount: '',
            });
            loadFines();
        } catch (error: any) {
            toast({
                title: "Assessment Failed",
                description: error.response?.data?.detail || "An error occurred",
                variant: "destructive",
            });
        } finally {
            setAssessing(false);
        }
    };

    const getStatusBadge = (status: string) => {
        const variants: Record<string, "default" | "secondary" | "destructive" | "outline"> = {
            'Paid': 'default',
            'Unpaid': 'destructive',
            'Partially Paid': 'secondary',
            'Waived': 'outline'
        };
        return <Badge variant={variants[status] || 'secondary'}>{status}</Badge>;
    };

    return (
        <div className="flex h-screen bg-background">
            <StaffSidebar />

            <div className="flex-1 flex flex-col overflow-hidden">
                <header className="border-b bg-background p-4 flex items-center justify-between">
                    <div>
                        <h1 className="text-2xl font-bold">Fines</h1>
                        <p className="text-sm text-muted-foreground">Manage patron fines and payments</p>
                    </div>
                    <div className="flex items-center gap-2">
                        <Button variant="outline" size="icon" onClick={() => setLocation('/')} title="Go to Home">
                            <Home className="h-5 w-5" />
                        </Button>
                        <ThemeToggle />
                    </div>
                </header>

                <main className="flex-1 overflow-y-auto p-8">
                    <Tabs defaultValue="list" className="space-y-6">
                        <TabsList>
                            <TabsTrigger value="list">Fine List</TabsTrigger>
                            <TabsTrigger value="pay">Pay Fine</TabsTrigger>
                            <TabsTrigger value="waive">Waive Fine</TabsTrigger>
                            <TabsTrigger value="assess">Assess Fine</TabsTrigger>
                        </TabsList>

                        <TabsContent value="list">
                            <Card>
                                <CardHeader>
                                    <CardTitle>All Fines</CardTitle>
                                    <CardDescription>
                                        View all patron fines
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <div className="space-y-4">
                                        <div className="flex items-center gap-4">
                                            <Label htmlFor="status-filter">Filter by Status:</Label>
                                            <Select value={statusFilter} onValueChange={setStatusFilter}>
                                                <SelectTrigger className="w-[200px]">
                                                    <SelectValue />
                                                </SelectTrigger>
                                                <SelectContent>
                                                    <SelectItem value="all">All</SelectItem>
                                                    <SelectItem value="Unpaid">Unpaid</SelectItem>
                                                    <SelectItem value="Paid">Paid</SelectItem>
                                                    <SelectItem value="Partially Paid">Partially Paid</SelectItem>
                                                    <SelectItem value="Waived">Waived</SelectItem>
                                                </SelectContent>
                                            </Select>
                                        </div>

                                        {finesLoading ? (
                                            <p className="text-sm text-muted-foreground text-center py-8">Loading...</p>
                                        ) : fines.length > 0 ? (
                                            <div className="border rounded-lg">
                                                <Table>
                                                    <TableHeader>
                                                        <TableRow>
                                                            <TableHead>Fine ID</TableHead>
                                                            <TableHead>Patron</TableHead>
                                                            <TableHead>Material</TableHead>
                                                            <TableHead>Type</TableHead>
                                                            <TableHead>Amount</TableHead>
                                                            <TableHead>Paid</TableHead>
                                                            <TableHead>Balance</TableHead>
                                                            <TableHead>Status</TableHead>
                                                            <TableHead>Date</TableHead>
                                                        </TableRow>
                                                    </TableHeader>
                                                    <TableBody>
                                                        {fines.map((fine) => (
                                                            <TableRow key={fine.fine_id}>
                                                                <TableCell>{fine.fine_id}</TableCell>
                                                                <TableCell>
                                                                    <div>
                                                                        <p className="font-medium">{fine.patron_name}</p>
                                                                        <p className="text-xs text-muted-foreground">{fine.patron_email}</p>
                                                                    </div>
                                                                </TableCell>
                                                                <TableCell>{fine.material_title || 'N/A'}</TableCell>
                                                                <TableCell>{fine.fine_type}</TableCell>
                                                                <TableCell>${fine.amount?.toFixed(2)}</TableCell>
                                                                <TableCell>${fine.amount_paid?.toFixed(2)}</TableCell>
                                                                <TableCell className="font-medium">${fine.balance?.toFixed(2)}</TableCell>
                                                                <TableCell>{getStatusBadge(fine.fine_status)}</TableCell>
                                                                <TableCell className="text-sm">{fine.issue_date}</TableCell>
                                                            </TableRow>
                                                        ))}
                                                    </TableBody>
                                                </Table>
                                            </div>
                                        ) : (
                                            <p className="text-sm text-muted-foreground text-center py-8">
                                                No fines found
                                            </p>
                                        )}
                                    </div>
                                </CardContent>
                            </Card>
                        </TabsContent>

                        <TabsContent value="pay">
                            <Card>
                                <CardHeader>
                                    <CardTitle className="flex items-center gap-2">
                                        <CreditCard className="h-5 w-5" />
                                        Process Fine Payment
                                    </CardTitle>
                                    <CardDescription>
                                        Record a fine payment from a patron
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <form onSubmit={handlePayFine} className="space-y-4">
                                        <div className="space-y-2">
                                            <Label htmlFor="fine-id">Fine ID</Label>
                                            <Input
                                                id="fine-id"
                                                type="number"
                                                placeholder="Enter fine ID"
                                                value={fineId}
                                                onChange={(e) => setFineId(e.target.value)}
                                                required
                                                disabled={loading}
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <Label htmlFor="payment-amount">Payment Amount</Label>
                                            <Input
                                                id="payment-amount"
                                                type="number"
                                                step="0.01"
                                                placeholder="0.00"
                                                value={paymentAmount}
                                                onChange={(e) => setPaymentAmount(e.target.value)}
                                                required
                                                disabled={loading}
                                            />
                                        </div>
                                        <Button type="submit" disabled={loading} className="w-full">
                                            <DollarSign className="mr-2 h-4 w-4" />
                                            {loading ? 'Processing...' : 'Process Payment'}
                                        </Button>
                                    </form>
                                </CardContent>
                            </Card>
                        </TabsContent>

                        <TabsContent value="waive">
                            <Card>
                                <CardHeader>
                                    <CardTitle className="flex items-center gap-2">
                                        <Ban className="h-5 w-5" />
                                        Waive Fine
                                    </CardTitle>
                                    <CardDescription>
                                        Waive a patron's fine with reason
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <form onSubmit={handleWaiveFine} className="space-y-4">
                                        <div className="space-y-2">
                                            <Label htmlFor="waive-fine-id">Fine ID</Label>
                                            <Input
                                                id="waive-fine-id"
                                                type="number"
                                                placeholder="Enter fine ID"
                                                value={fineId}
                                                onChange={(e) => setFineId(e.target.value)}
                                                required
                                                disabled={loading}
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <Label htmlFor="waive-reason">Reason for Waiving</Label>
                                            <Textarea
                                                id="waive-reason"
                                                placeholder="Enter reason for waiving fine"
                                                value={waiveReason}
                                                onChange={(e) => setWaiveReason(e.target.value)}
                                                required
                                                disabled={loading}
                                            />
                                        </div>
                                        <Button type="submit" disabled={loading} variant="destructive" className="w-full">
                                            {loading ? 'Processing...' : 'Waive Fine'}
                                        </Button>
                                    </form>
                                </CardContent>
                            </Card>
                        </TabsContent>

                        <TabsContent value="assess">
                            <Card>
                                <CardHeader>
                                    <CardTitle className="flex items-center gap-2">
                                        <AlertCircle className="h-5 w-5" />
                                        Assess Fine
                                    </CardTitle>
                                    <CardDescription>
                                        Manually assess a fine to a patron
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <form onSubmit={handleAssessFine} className="space-y-4">
                                        <div className="grid grid-cols-2 gap-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="assess-patron-id">Patron ID *</Label>
                                                <Input
                                                    id="assess-patron-id"
                                                    type="number"
                                                    placeholder="Enter patron ID"
                                                    value={assessForm.patron_id}
                                                    onChange={(e) => setAssessForm({ ...assessForm, patron_id: e.target.value })}
                                                    required
                                                    disabled={assessing}
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="assess-loan-id">Loan ID (Optional)</Label>
                                                <Input
                                                    id="assess-loan-id"
                                                    type="number"
                                                    placeholder="Enter loan ID"
                                                    value={assessForm.loan_id}
                                                    onChange={(e) => setAssessForm({ ...assessForm, loan_id: e.target.value })}
                                                    disabled={assessing}
                                                />
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-2 gap-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="fine-type">Fine Type *</Label>
                                                <Select
                                                    value={assessForm.fine_type}
                                                    onValueChange={(value) => setAssessForm({ ...assessForm, fine_type: value })}
                                                >
                                                    <SelectTrigger>
                                                        <SelectValue />
                                                    </SelectTrigger>
                                                    <SelectContent>
                                                        <SelectItem value="Overdue">Overdue</SelectItem>
                                                        <SelectItem value="Lost">Lost</SelectItem>
                                                        <SelectItem value="Damaged">Damaged</SelectItem>
                                                        <SelectItem value="Other">Other</SelectItem>
                                                    </SelectContent>
                                                </Select>
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="assess-amount">Amount *</Label>
                                                <Input
                                                    id="assess-amount"
                                                    type="number"
                                                    step="0.01"
                                                    placeholder="0.00"
                                                    value={assessForm.amount}
                                                    onChange={(e) => setAssessForm({ ...assessForm, amount: e.target.value })}
                                                    required
                                                    disabled={assessing}
                                                />
                                            </div>
                                        </div>

                                        <Button type="submit" disabled={assessing} className="w-full">
                                            <AlertCircle className="mr-2 h-4 w-4" />
                                            {assessing ? 'Assessing...' : 'Assess Fine'}
                                        </Button>
                                    </form>
                                </CardContent>
                            </Card>
                        </TabsContent>
                    </Tabs>
                </main>
            </div>
        </div>
    );
}
