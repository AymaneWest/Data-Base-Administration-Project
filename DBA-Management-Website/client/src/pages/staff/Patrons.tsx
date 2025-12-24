import { StaffSidebar } from "@/components/StaffSidebar";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ThemeToggle } from "@/components/ThemeToggle";
import { Users, UserPlus, UserCheck, UserX, Home, Search } from "lucide-react";
import { useState } from "react";
import * as api from "@/lib/api";
import { useToast } from "@/hooks/use-toast";
import { getUserId } from "@/lib/auth-utils";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { useLocation } from "wouter";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";

export default function Patrons() {
    const { toast } = useToast();
    const staffId = getUserId();
    const [, setLocation] = useLocation();

    // Search state
    const [searchTerm, setSearchTerm] = useState('');
    const [searchResults, setSearchResults] = useState<any[]>([]);
    const [searching, setSearching] = useState(false);

    // Registration state
    const [registerForm, setRegisterForm] = useState({
        card_number: '',
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        address: '',
        date_of_birth: '',
        membership_type: 'Standard',
        branch_id: 1
    });
    const [registering, setRegistering] = useState(false);

    // Patron actions state
    const [patronId, setPatronId] = useState('');
    const [suspendReason, setSuspendReason] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSearch = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!searchTerm.trim()) return;

        setSearching(true);
        try {
            const response = await api.searchPatrons(searchTerm);
            setSearchResults(response.data?.patrons || []);
            toast({
                title: "Search Complete",
                description: `Found ${response.data?.count || 0} patron(s)`,
            });
        } catch (error: any) {
            toast({
                title: "Search Failed",
                description: error.response?.data?.detail || "An error occurred",
                variant: "destructive",
            });
        } finally {
            setSearching(false);
        }
    };

    const handleRegister = async (e: React.FormEvent) => {
        e.preventDefault();
        setRegistering(true);

        try {
            const response = await api.registerPatron(registerForm);
            toast({
                title: "Registration Successful",
                description: `Patron registered with ID: ${response.data?.patron_id}`,
            });
            // Reset form
            setRegisterForm({
                card_number: '',
                first_name: '',
                last_name: '',
                email: '',
                phone: '',
                address: '',
                date_of_birth: '',
                membership_type: 'Standard',
                branch_id: 1
            });
        } catch (error: any) {
            toast({
                title: "Registration Failed",
                description: error.response?.data?.detail || "An error occurred",
                variant: "destructive",
            });
        } finally {
            setRegistering(false);
        }
    };

    const handleRenewMembership = async () => {
        if (!patronId) return;

        setLoading(true);
        try {
            await api.renewMembership(parseInt(patronId));
            toast({
                title: "Membership Renewed",
                description: "Patron membership has been renewed successfully",
            });
            setPatronId('');
        } catch (error: any) {
            toast({
                title: "Error",
                description: error.response?.data?.detail || "Failed to renew membership",
                variant: "destructive",
            });
        } finally {
            setLoading(false);
        }
    };

    const handleSuspendPatron = async () => {
        if (!patronId || !suspendReason) return;

        setLoading(true);
        try {
            await api.suspendPatron(parseInt(patronId), suspendReason, staffId);
            toast({
                title: "Patron Suspended",
                description: "Patron has been suspended",
            });
            setPatronId('');
            setSuspendReason('');
        } catch (error: any) {
            toast({
                title: "Error",
                description: error.response?.data?.detail || "Failed to suspend patron",
                variant: "destructive",
            });
        } finally {
            setLoading(false);
        }
    };

    const handleReactivatePatron = async () => {
        if (!patronId) return;

        setLoading(true);
        try {
            await api.reactivatePatron(parseInt(patronId), staffId);
            toast({
                title: "Patron Reactivated",
                description: "Patron has been reactivated successfully",
            });
            setPatronId('');
        } catch (error: any) {
            toast({
                title: "Error",
                description: error.response?.data?.detail || "Failed to reactivate patron",
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
                        <h1 className="text-2xl font-bold">Patrons</h1>
                        <p className="text-sm text-muted-foreground">Manage library patrons</p>
                    </div>
                    <div className="flex items-center gap-2">
                        <Button variant="outline" size="icon" onClick={() => setLocation('/')} title="Go to Home">
                            <Home className="h-5 w-5" />
                        </Button>
                        <ThemeToggle />
                    </div>
                </header>

                <main className="flex-1 overflow-y-auto p-8">
                    <Tabs defaultValue="search" className="space-y-6">
                        <TabsList>
                            <TabsTrigger value="search">Search</TabsTrigger>
                            <TabsTrigger value="register">Register</TabsTrigger>
                            <TabsTrigger value="manage">Manage</TabsTrigger>
                        </TabsList>

                        <TabsContent value="search">
                            <Card>
                                <CardHeader>
                                    <CardTitle>Search Patrons</CardTitle>
                                    <CardDescription>
                                        Search for patrons by ID, name, or email
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <form onSubmit={handleSearch} className="space-y-4">
                                        <div className="flex gap-4">
                                            <Input
                                                placeholder="Search by Patron ID, Name, or Email..."
                                                value={searchTerm}
                                                onChange={(e) => setSearchTerm(e.target.value)}
                                                className="flex-1"
                                            />
                                            <Button type="submit" disabled={searching}>
                                                <Search className="mr-2 h-4 w-4" />
                                                {searching ? 'Searching...' : 'Search'}
                                            </Button>
                                        </div>
                                    </form>

                                    {searchResults.length > 0 && (
                                        <div className="mt-6">
                                            <h3 className="font-semibold mb-4">Results ({searchResults.length})</h3>
                                            <div className="border rounded-lg">
                                                <Table>
                                                    <TableHeader>
                                                        <TableRow>
                                                            <TableHead>ID</TableHead>
                                                            <TableHead>Name</TableHead>
                                                            <TableHead>Email</TableHead>
                                                            <TableHead>Phone</TableHead>
                                                            <TableHead>Status</TableHead>
                                                            <TableHead>Membership</TableHead>
                                                        </TableRow>
                                                    </TableHeader>
                                                    <TableBody>
                                                        {searchResults.map((patron) => (
                                                            <TableRow key={patron.patron_id}>
                                                                <TableCell>{patron.patron_id}</TableCell>
                                                                <TableCell>{patron.first_name} {patron.last_name}</TableCell>
                                                                <TableCell>{patron.email}</TableCell>
                                                                <TableCell>{patron.phone}</TableCell>
                                                                <TableCell>
                                                                    <Badge variant={patron.patron_status === 'Active' ? 'default' : 'destructive'}>
                                                                        {patron.patron_status}
                                                                    </Badge>
                                                                </TableCell>
                                                                <TableCell>{patron.membership_type}</TableCell>
                                                            </TableRow>
                                                        ))}
                                                    </TableBody>
                                                </Table>
                                            </div>
                                        </div>
                                    )}
                                </CardContent>
                            </Card>
                        </TabsContent>

                        <TabsContent value="register">
                            <Card>
                                <CardHeader>
                                    <CardTitle>Register New Patron</CardTitle>
                                    <CardDescription>
                                        Create a new patron account
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <form onSubmit={handleRegister} className="space-y-4">
                                        <div className="grid grid-cols-2 gap-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="card_number">Card Number</Label>
                                                <Input
                                                    id="card_number"
                                                    value={registerForm.card_number}
                                                    onChange={(e) => setRegisterForm({ ...registerForm, card_number: e.target.value })}
                                                    required
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="membership_type">Membership Type</Label>
                                                <Select
                                                    value={registerForm.membership_type}
                                                    onValueChange={(value) => setRegisterForm({ ...registerForm, membership_type: value })}
                                                >
                                                    <SelectTrigger>
                                                        <SelectValue />
                                                    </SelectTrigger>
                                                    <SelectContent>
                                                        <SelectItem value="Standard">Standard</SelectItem>
                                                        <SelectItem value="Premium">Premium</SelectItem>
                                                        <SelectItem value="Student">Student</SelectItem>
                                                    </SelectContent>
                                                </Select>
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-2 gap-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="first_name">First Name</Label>
                                                <Input
                                                    id="first_name"
                                                    value={registerForm.first_name}
                                                    onChange={(e) => setRegisterForm({ ...registerForm, first_name: e.target.value })}
                                                    required
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="last_name">Last Name</Label>
                                                <Input
                                                    id="last_name"
                                                    value={registerForm.last_name}
                                                    onChange={(e) => setRegisterForm({ ...registerForm, last_name: e.target.value })}
                                                    required
                                                />
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-2 gap-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="email">Email</Label>
                                                <Input
                                                    id="email"
                                                    type="email"
                                                    value={registerForm.email}
                                                    onChange={(e) => setRegisterForm({ ...registerForm, email: e.target.value })}
                                                    required
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="phone">Phone</Label>
                                                <Input
                                                    id="phone"
                                                    value={registerForm.phone}
                                                    onChange={(e) => setRegisterForm({ ...registerForm, phone: e.target.value })}
                                                    required
                                                />
                                            </div>
                                        </div>

                                        <div className="space-y-2">
                                            <Label htmlFor="address">Address</Label>
                                            <Textarea
                                                id="address"
                                                value={registerForm.address}
                                                onChange={(e) => setRegisterForm({ ...registerForm, address: e.target.value })}
                                                required
                                            />
                                        </div>

                                        <div className="grid grid-cols-2 gap-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="date_of_birth">Date of Birth</Label>
                                                <Input
                                                    id="date_of_birth"
                                                    type="date"
                                                    value={registerForm.date_of_birth}
                                                    onChange={(e) => setRegisterForm({ ...registerForm, date_of_birth: e.target.value })}
                                                    required
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="branch_id">Branch ID</Label>
                                                <Input
                                                    id="branch_id"
                                                    type="number"
                                                    value={registerForm.branch_id}
                                                    onChange={(e) => setRegisterForm({ ...registerForm, branch_id: parseInt(e.target.value) })}
                                                    required
                                                />
                                            </div>
                                        </div>

                                        <Button type="submit" disabled={registering} className="w-full">
                                            <UserPlus className="mr-2 h-4 w-4" />
                                            {registering ? 'Registering...' : 'Register Patron'}
                                        </Button>
                                    </form>
                                </CardContent>
                            </Card>
                        </TabsContent>

                        <TabsContent value="manage">
                            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                                <Card>
                                    <CardHeader>
                                        <CardTitle className="flex items-center gap-2">
                                            <UserCheck className="h-5 w-5" />
                                            Renew Membership
                                        </CardTitle>
                                        <CardDescription>
                                            Extend patron membership
                                        </CardDescription>
                                    </CardHeader>
                                    <CardContent>
                                        <div className="space-y-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="renew-patron-id">Patron ID</Label>
                                                <Input
                                                    id="renew-patron-id"
                                                    type="number"
                                                    placeholder="Enter patron ID"
                                                    value={patronId}
                                                    onChange={(e) => setPatronId(e.target.value)}
                                                    disabled={loading}
                                                />
                                            </div>
                                            <Button
                                                onClick={handleRenewMembership}
                                                disabled={loading || !patronId}
                                                className="w-full"
                                            >
                                                Renew Membership
                                            </Button>
                                        </div>
                                    </CardContent>
                                </Card>

                                <Card>
                                    <CardHeader>
                                        <CardTitle className="flex items-center gap-2">
                                            <UserX className="h-5 w-5" />
                                            Suspend Patron
                                        </CardTitle>
                                        <CardDescription>
                                            Temporarily suspend patron account
                                        </CardDescription>
                                    </CardHeader>
                                    <CardContent>
                                        <div className="space-y-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="suspend-patron-id">Patron ID</Label>
                                                <Input
                                                    id="suspend-patron-id"
                                                    type="number"
                                                    placeholder="Enter patron ID"
                                                    value={patronId}
                                                    onChange={(e) => setPatronId(e.target.value)}
                                                    disabled={loading}
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <Label htmlFor="suspend-reason">Reason</Label>
                                                <Textarea
                                                    id="suspend-reason"
                                                    placeholder="Enter reason for suspension"
                                                    value={suspendReason}
                                                    onChange={(e) => setSuspendReason(e.target.value)}
                                                    disabled={loading}
                                                />
                                            </div>
                                            <Button
                                                onClick={handleSuspendPatron}
                                                disabled={loading || !patronId || !suspendReason}
                                                variant="destructive"
                                                className="w-full"
                                            >
                                                Suspend Patron
                                            </Button>
                                        </div>
                                    </CardContent>
                                </Card>

                                <Card>
                                    <CardHeader>
                                        <CardTitle className="flex items-center gap-2">
                                            <UserPlus className="h-5 w-5" />
                                            Reactivate Patron
                                        </CardTitle>
                                        <CardDescription>
                                            Reactivate suspended patron
                                        </CardDescription>
                                    </CardHeader>
                                    <CardContent>
                                        <div className="space-y-4">
                                            <div className="space-y-2">
                                                <Label htmlFor="reactivate-patron-id">Patron ID</Label>
                                                <Input
                                                    id="reactivate-patron-id"
                                                    type="number"
                                                    placeholder="Enter patron ID"
                                                    value={patronId}
                                                    onChange={(e) => setPatronId(e.target.value)}
                                                    disabled={loading}
                                                />
                                            </div>
                                            <Button
                                                onClick={handleReactivatePatron}
                                                disabled={loading || !patronId}
                                                className="w-full"
                                            >
                                                Reactivate Patron
                                            </Button>
                                        </div>
                                    </CardContent>
                                </Card>
                            </div>
                        </TabsContent>
                    </Tabs>
                </main>
            </div>
        </div>
    );
}
