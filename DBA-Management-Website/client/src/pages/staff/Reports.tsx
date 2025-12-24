import { StaffSidebar } from "@/components/StaffSidebar";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ThemeToggle } from "@/components/ThemeToggle";
import { TrendingUp, FileText, Calendar } from "lucide-react";
import { useState } from "react";
import * as api from "@/lib/api";
import { useToast } from "@/hooks/use-toast";

export default function Reports() {
    const { toast } = useToast();
    const [branchId, setBranchId] = useState('');
    const [patronId, setPatronId] = useState('');
    const [materialId, setMaterialId] = useState('');
    const [reportData, setReportData] = useState<any>(null);
    const [loading, setLoading] = useState(false);

    const handleOverdueReport = async () => {
        setLoading(true);
        try {
            const response = await api.getOverdueCount(branchId ? parseInt(branchId) : undefined);
            setReportData({ type: 'overdue', data: response.data });
            toast({
                title: "Report Generated",
                description: "Overdue items report loaded",
            });
        } catch (error: any) {
            toast({
                title: "Error",
                description: error.response?.data?.detail || "Failed to generate report",
                variant: "destructive",
            });
        } finally {
            setLoading(false);
        }
    };

    const handleFinesReport = async () => {
        setLoading(true);
        try {
            const response = await api.getTotalFines(patronId ? parseInt(patronId) : undefined);
            setReportData({ type: 'fines', data: response.data });
            toast({
                title: "Report Generated",
                description: "Fines report loaded",
            });
        } catch (error: any) {
            toast({
                title: "Error",
                description: error.response?.data?.detail || "Failed to generate report",
                variant: "destructive",
            });
        } finally {
            setLoading(false);
        }
    };

    const handleAvailabilityReport = async () => {
        if (!materialId) return;

        setLoading(true);
        try {
            const response = await api.checkMaterialAvailability(parseInt(materialId));
            setReportData({ type: 'availability', data: response.data });
            toast({
                title: "Report Generated",
                description: "Material availability report loaded",
            });
        } catch (error: any) {
            toast({
                title: "Error",
                description: error.response?.data?.detail || "Failed to generate report",
                variant: "destructive",
            });
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
                        <h1 className="text-2xl font-bold">Reports</h1>
                        <p className="text-sm text-muted-foreground">Generate library reports</p>
                    </div>
                    <ThemeToggle />
                </header>

                <main className="flex-1 overflow-y-auto p-8">
                    <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                        <Card>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2">
                                    <Calendar className="h-5 w-5" />
                                    Overdue Items
                                </CardTitle>
                                <CardDescription>
                                    Check overdue items count
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                <div className="space-y-2">
                                    <Label htmlFor="overdue-branch">Branch ID (Optional)</Label>
                                    <Input
                                        id="overdue-branch"
                                        type="number"
                                        placeholder="Leave empty for all branches"
                                        value={branchId}
                                        onChange={(e) => setBranchId(e.target.value)}
                                        disabled={loading}
                                    />
                                </div>
                                <Button onClick={handleOverdueReport} disabled={loading} className="w-full">
                                    {loading ? 'Loading...' : 'Generate Report'}
                                </Button>
                            </CardContent>
                        </Card>

                        <Card>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2">
                                    <FileText className="h-5 w-5" />
                                    Total Fines
                                </CardTitle>
                                <CardDescription>
                                    Calculate total fines
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                <div className="space-y-2">
                                    <Label htmlFor="fines-patron">Patron ID (Optional)</Label>
                                    <Input
                                        id="fines-patron"
                                        type="number"
                                        placeholder="Leave empty for all patrons"
                                        value={patronId}
                                        onChange={(e) => setPatronId(e.target.value)}
                                        disabled={loading}
                                    />
                                </div>
                                <Button onClick={handleFinesReport} disabled={loading} className="w-full">
                                    {loading ? 'Loading...' : 'Generate Report'}
                                </Button>
                            </CardContent>
                        </Card>

                        <Card>
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2">
                                    <TrendingUp className="h-5 w-5" />
                                    Material Availability
                                </CardTitle>
                                <CardDescription>
                                    Check material availability
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                <div className="space-y-2">
                                    <Label htmlFor="availability-material">Material ID</Label>
                                    <Input
                                        id="availability-material"
                                        type="number"
                                        placeholder="Enter material ID"
                                        value={materialId}
                                        onChange={(e) => setMaterialId(e.target.value)}
                                        disabled={loading}
                                    />
                                </div>
                                <Button onClick={handleAvailabilityReport} disabled={loading} className="w-full">
                                    {loading ? 'Loading...' : 'Check Availability'}
                                </Button>
                            </CardContent>
                        </Card>
                    </div>

                    {reportData && (
                        <Card className="mt-6">
                            <CardHeader>
                                <CardTitle>Report Results</CardTitle>
                                <CardDescription>
                                    {reportData.type} report data
                                </CardDescription>
                            </CardHeader>
                            <CardContent>
                                <pre className="text-xs overflow-auto bg-muted p-4 rounded">
                                    {JSON.stringify(reportData.data, null, 2)}
                                </pre>
                            </CardContent>
                        </Card>
                    )}
                </main>
            </div>
        </div>
    );
}
