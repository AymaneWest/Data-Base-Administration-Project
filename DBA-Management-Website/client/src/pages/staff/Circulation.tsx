import { StaffSidebar } from "@/components/StaffSidebar";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ThemeToggle } from "@/components/ThemeToggle";
import { BookOpen, RotateCcw, Home } from "lucide-react";
import { useState } from "react";
import * as api from "@/lib/api";
import { useToast } from "@/hooks/use-toast";
import { getUserId } from "@/lib/auth-utils";
import { useLocation } from "wouter";

export default function Circulation() {
    const { toast } = useToast();
    const staffId = getUserId();
    const [, setLocation] = useLocation();

    // C Checkout state
    const [checkoutPatronId, setCheckoutPatronId] = useState('');
    const [checkoutCopyId, setCheckoutCopyId] = useState('');
    const [checkingOut, setCheckingOut] = useState(false);

    // Return state
    const [returnCopyId, setReturnCopyId] = useState('');
    const [returning, setReturning] = useState(false);

    const handleCheckout = async (e: React.FormEvent) => {
        e.preventDefault();
        setCheckingOut(true);

        try {
            const response = await api.checkoutItem({
                patron_id: parseInt(checkoutPatronId),
                copy_id: parseInt(checkoutCopyId),
                staff_id: staffId
            });

            toast({
                title: "Checkout Successful",
                description: "Item has been checked out to patron",
            });

            // Clear form
            setCheckoutPatronId('');
            setCheckoutCopyId('');
        } catch (error: any) {
            toast({
                title: "Checkout Failed",
                description: error.response?.data?.detail || "An error occurred",
                variant: "destructive",
            });
        } finally {
            setCheckingOut(false);
        }
    };

    const handleReturn = async (e: React.FormEvent) => {
        e.preventDefault();
        setReturning(true);

        try {
            const response = await api.checkinItem({
                loan_id: parseInt(returnCopyId),
                staff_id: staffId
            });

            toast({
                title: "Return Successful",
                description: response.data?.message || "Item has been returned",
            });

            // Clear form
            setReturnCopyId('');
        } catch (error: any) {
            toast({
                title: "Return Failed",
                description: error.response?.data?.detail || error.response?.data?.message || "An error occurred",
                variant: "destructive",
            });
        } finally {
            setReturning(false);
        }
    };

    return (
        <div className="flex h-screen bg-background">
            <StaffSidebar />

            <div className="flex-1 flex flex-col overflow-hidden">
                <header className="border-b bg-background p-4 flex items-center justify-between">
                    <div>
                        <h1 className="text-2xl font-bold">Circulation</h1>
                        <p className="text-sm text-muted-foreground">Manage checkouts and returns</p>
                    </div>
                    <div className="flex items-center gap-2">
                        <Button variant="outline" size="icon" onClick={() => setLocation('/')} title="Go to Home">
                            <Home className="h-5 w-5" />
                        </Button>
                        <ThemeToggle />
                    </div>
                </header>

                <main className="flex-1 overflow-y-auto p-8">
                    <Tabs defaultValue="checkout" className="space-y-6">
                        <TabsList>
                            <TabsTrigger value="checkout">Checkout</TabsTrigger>
                            <TabsTrigger value="return">Return</TabsTrigger>
                        </TabsList>

                        <TabsContent value="checkout">
                            <Card>
                                <CardHeader>
                                    <CardTitle>Checkout Item</CardTitle>
                                    <CardDescription>
                                        Check out an item to a patron
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <form onSubmit={handleCheckout} className="space-y-4">
                                        <div className="space-y-2">
                                            <Label htmlFor="patron-id">Patron ID</Label>
                                            <Input
                                                id="patron-id"
                                                type="number"
                                                placeholder="Enter patron ID"
                                                value={checkoutPatronId}
                                                onChange={(e) => setCheckoutPatronId(e.target.value)}
                                                required
                                                disabled={checkingOut}
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <Label htmlFor="copy-id">Copy ID / Barcode</Label>
                                            <Input
                                                id="copy-id"
                                                type="number"
                                                placeholder="Enter copy ID or scan barcode"
                                                value={checkoutCopyId}
                                                onChange={(e) => setCheckoutCopyId(e.target.value)}
                                                required
                                                disabled={checkingOut}
                                            />
                                        </div>
                                        <Button type="submit" disabled={checkingOut} className="w-full">
                                            <BookOpen className="mr-2 h-4 w-4" />
                                            {checkingOut ? 'Checking Out...' : 'Checkout Item'}
                                        </Button>
                                    </form>
                                </CardContent>
                            </Card>
                        </TabsContent>

                        <TabsContent value="return">
                            <Card>
                                <CardHeader>
                                    <CardTitle>Return Item</CardTitle>
                                    <CardDescription>
                                        Process item return
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <form onSubmit={handleReturn} className="space-y-4">
                                        <div className="space-y-2">
                                            <Label htmlFor="return-copy-id">Loan ID</Label>
                                            <Input
                                                id="return-copy-id"
                                                type="number"
                                                placeholder="Enter loan ID"
                                                value={returnCopyId}
                                                onChange={(e) => setReturnCopyId(e.target.value)}
                                                required
                                                disabled={returning}
                                            />
                                        </div>
                                        <Button type="submit" disabled={returning} className="w-full">
                                            <RotateCcw className="mr-2 h-4 w-4" />
                                            {returning ? 'Processing Return...' : 'Return Item'}
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
