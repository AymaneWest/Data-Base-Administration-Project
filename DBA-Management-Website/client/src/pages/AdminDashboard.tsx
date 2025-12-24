import React, { useState } from 'react';
import { useLocation } from 'wouter';
import { useAuth } from '@/lib/auth';
import * as api from '@/lib/api';
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useToast } from "@/hooks/use-toast";

const AdminDashboard: React.FC = () => {
    const { logout, user } = useAuth();
    const [, setLocation] = useLocation();
    const { toast } = useToast();
    const [activeTab, setActiveTab] = useState('overview');
    const [result, setResult] = useState<any>(null);
    const [error, setError] = useState('');

    const handleLogout = async () => {
        try {
            await logout();
            setLocation('/login');
        } catch (err) {
            console.error('Logout error:', err);
            setLocation('/login');
        }
    };

    const handleApiCall = async (apiFunc: () => Promise<any>, successMsg: string) => {
        setError('');
        setResult(null);
        try {
            const response = await apiFunc();
            setResult({ success: true, data: response.data, message: successMsg });
            toast({
                title: "Success",
                description: successMsg,
            });
        } catch (err: any) {
            const errorMsg = err.response?.data?.detail || err.message || 'An error occurred';
            setError(errorMsg);
            toast({
                title: "Error",
                description: errorMsg,
                variant: "destructive",
            });
        }
    };

    return (
        <div className="min-h-screen bg-background">
            <header className="border-b">
                <div className="container mx-auto px-4 py-4 flex justify-between items-center">
                    <div>
                        <h1 className="text-2xl font-bold">Admin Dashboard</h1>
                        <p className="text-sm text-muted-foreground">Welcome{user?.username ? `, ${user.username}` : ''}</p>
                    </div>
                    <div className="flex gap-2">
                        <Button variant="outline" onClick={() => setLocation('/')}>Home</Button>
                        <Button variant="outline" onClick={() => setLocation('/staff')}>Staff Dashboard</Button>
                        <Button variant="destructive" onClick={handleLogout}>Logout</Button>
                    </div>
                </div>
            </header>

            <div className="container mx-auto px-4 py-8">
                <Tabs value={activeTab} onValueChange={setActiveTab}>
                    <TabsList className="grid w-full grid-cols-4">
                        <TabsTrigger value="overview">Overview</TabsTrigger>
                        <TabsTrigger value="users">User Management</TabsTrigger>
                        <TabsTrigger value="reports">Reports</TabsTrigger>
                        <TabsTrigger value="batch">Batch Operations</TabsTrigger>
                    </TabsList>

                    <TabsContent value="overview" className="space-y-4">
                        <OverviewSection />
                    </TabsContent>

                    <TabsContent value="users" className="space-y-4">
                        <UserManagementSection onApiCall={handleApiCall} />
                    </TabsContent>

                    <TabsContent value="reports" className="space-y-4">
                        <ReportingSection onApiCall={handleApiCall} />
                    </TabsContent>

                    <TabsContent value="batch" className="space-y-4">
                        <BatchOperationsSection onApiCall={handleApiCall} />
                    </TabsContent>
                </Tabs>

                {/* Results Display */}
                {result && (
                    <Card className="mt-6 border-green-500">
                        <CardHeader>
                            <CardTitle className="text-green-600">Success</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <p className="mb-2">{result.message}</p>
                            <pre className="mt-2 text-xs overflow-auto max-h-96 bg-muted p-4 rounded">
                                {JSON.stringify(result.data, null, 2)}
                            </pre>
                        </CardContent>
                    </Card>
                )}
                {error && (
                    <Card className="mt-6 border-red-500">
                        <CardHeader>
                            <CardTitle className="text-red-600">Error</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <p>{error}</p>
                        </CardContent>
                    </Card>
                )}
            </div>
        </div>
    );
};

const OverviewSection: React.FC = () => {
    return (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card>
                <CardHeader>
                    <CardTitle className="text-sm font-medium">System Admin</CardTitle>
                </CardHeader>
                <CardContent>
                    <p className="text-2xl font-bold">Full Access</p>
                    <p className="text-xs text-muted-foreground">All system permissions</p>
                </CardContent>
            </Card>
            <Card>
                <CardHeader>
                    <CardTitle className="text-sm font-medium">User Management</CardTitle>
                </CardHeader>
                <CardContent>
                    <p className="text-2xl font-bold">Active</p>
                    <p className="text-xs text-muted-foreground">Manage roles and permissions</p>
                </CardContent>
            </Card>
            <Card>
                <CardHeader>
                    <CardTitle className="text-sm font-medium">Reports</CardTitle>
                </CardHeader>
                <CardContent>
                    <p className="text-2xl font-bold">Available</p>
                    <p className="text-xs text-muted-foreground">System-wide analytics</p>
                </CardContent>
            </Card>
            <Card>
                <CardHeader>
                    <CardTitle className="text-sm font-medium">Batch Operations</CardTitle>
                </CardHeader>
                <CardContent>
                    <p className="text-2xl font-bold">Ready</p>
                    <p className="text-xs text-muted-foreground">Automated maintenance</p>
                </CardContent>
            </Card>
        </div>
    );
};

const UserManagementSection: React.FC<{ onApiCall: Function }> = ({ onApiCall }) => {
    const [userId, setUserId] = useState('');
    const [roleId, setRoleId] = useState('');
    const [permissionCode, setPermissionCode] = useState('');
    const [roleCode, setRoleCode] = useState('');

    return (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            <Card>
                <CardHeader>
                    <CardTitle>Get User Status</CardTitle>
                    <CardDescription>Check user account status</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-2">
                        <Label htmlFor="user-status-id">User ID</Label>
                        <Input
                            id="user-status-id"
                            type="number"
                            placeholder="User ID"
                            value={userId}
                            onChange={(e) => setUserId(e.target.value)}
                        />
                        <Button
                            onClick={() => onApiCall(() => api.getUserStatus(parseInt(userId)), 'User status retrieved')}
                            className="w-full"
                        >
                            Get Status
                        </Button>
                    </div>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Get User Roles</CardTitle>
                    <CardDescription>View assigned user roles</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-2">
                        <Label htmlFor="user-roles-id">User ID</Label>
                        <Input
                            id="user-roles-id"
                            type="number"
                            placeholder="User ID"
                            value={userId}
                            onChange={(e) => setUserId(e.target.value)}
                        />
                        <Button
                            onClick={() => onApiCall(() => api.getUserRoles(parseInt(userId)), 'User roles retrieved')}
                            className="w-full"
                        >
                            Get Roles
                        </Button>
                    </div>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Assign Role</CardTitle>
                    <CardDescription>Assign role to user</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-2">
                        <Label htmlFor="assign-user-id">User ID</Label>
                        <Input
                            id="assign-user-id"
                            type="number"
                            placeholder="User ID"
                            value={userId}
                            onChange={(e) => setUserId(e.target.value)}
                        />
                        <Label htmlFor="assign-role-id">Role ID</Label>
                        <Input
                            id="assign-role-id"
                            type="number"
                            placeholder="Role ID"
                            value={roleId}
                            onChange={(e) => setRoleId(e.target.value)}
                        />
                        <Button
                            onClick={() => onApiCall(() => api.assignRole({ user_id: parseInt(userId), role_id: parseInt(roleId) }), 'Role assigned')}
                            className="w-full" variant="default"
                        >
                            Assign Role
                        </Button>
                    </div>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Revoke Role</CardTitle>
                    <CardDescription>Remove role from user</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-2">
                        <Label htmlFor="revoke-user-id">User ID</Label>
                        <Input
                            id="revoke-user-id"
                            type="number"
                            placeholder="User ID"
                            value={userId}
                            onChange={(e) => setUserId(e.target.value)}
                        />
                        <Label htmlFor="revoke-role-id">Role ID</Label>
                        <Input
                            id="revoke-role-id"
                            type="number"
                            placeholder="Role ID"
                            value={roleId}
                            onChange={(e) => setRoleId(e.target.value)}
                        />
                        <Button
                            onClick={() => onApiCall(() => api.revokeRole({ user_id: parseInt(userId), role_id: parseInt(roleId) }), 'Role revoked')}
                            className="w-full"
                            variant="destructive"
                        >
                            Revoke Role
                        </Button>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
};

const ReportingSection: React.FC<{ onApiCall: Function }> = ({ onApiCall }) => {
    const [branchId, setBranchId] = useState('');
    const [patronId, setPatronId] = useState('');
    const [materialId, setMaterialId] = useState('');

    return (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            <Card>
                <CardHeader>
                    <CardTitle>Overdue Count</CardTitle>
                    <CardDescription>Check overdue items</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-2">
                        <Label htmlFor="overdue-branch">Branch ID (Optional)</Label>
                        <Input
                            id="overdue-branch"
                            type="number"
                            placeholder="Branch ID"
                            value={branchId}
                            onChange={(e) => setBranchId(e.target.value)}
                        />
                        <Button
                            onClick={() => onApiCall(() => api.getOverdueCount(branchId ? parseInt(branchId) : undefined), 'Overdue count retrieved')}
                            className="w-full"
                        >
                            Get Count
                        </Button>
                    </div>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Total Fines</CardTitle>
                    <CardDescription>Calculate outstanding fines</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-2">
                        <Label htmlFor="fines-patron">Patron ID (Optional)</Label>
                        <Input
                            id="fines-patron"
                            type="number"
                            placeholder="Patron ID"
                            value={patronId}
                            onChange={(e) => setPatronId(e.target.value)}
                        />
                        <Button
                            onClick={() => onApiCall(() => api.getTotalFines(patronId ? parseInt(patronId) : undefined), 'Total fines calculated')}
                            className="w-full"
                        >
                            Calculate
                        </Button>
                    </div>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Material Availability</CardTitle>
                    <CardDescription>Check material status</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-2">
                        <Label htmlFor="availability-material">Material ID</Label>
                        <Input
                            id="availability-material"
                            type="number"
                            placeholder="Material ID"
                            value={materialId}
                            onChange={(e) => setMaterialId(e.target.value)}
                        />
                        <Button
                            onClick={() => onApiCall(() => api.checkMaterialAvailability(parseInt(materialId)), 'Availability checked')}
                            className="w-full"
                        >
                            Check
                        </Button>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
};

const BatchOperationsSection: React.FC<{ onApiCall: Function }> = ({ onApiCall }) => {
    const [branchId, setBranchId] = useState('');

    return (
        <div className="grid gap-4 md:grid-cols-2">
            <Card>
                <CardHeader>
                    <CardTitle>Process Overdue Notifications</CardTitle>
                    <CardDescription>Send notifications for all overdue items</CardDescription>
                </CardHeader>
                <CardContent>
                    <Button
                        onClick={() => onApiCall(() => api.processOverdueNotifications(), 'Notifications processed')}
                        className="w-full"
                        variant="default"
                    >
                        Process Notifications
                    </Button>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Expire Memberships</CardTitle>
                    <CardDescription>Mark expired memberships as inactive</CardDescription>
                </CardHeader>
                <CardContent>
                    <Button
                        onClick={() => onApiCall(() => api.expireMemberships(), 'Memberships expired')}
                        className="w-full"
                        variant="destructive"
                    >
                        Expire Memberships
                    </Button>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Cleanup Reservations</CardTitle>
                    <CardDescription>Remove expired reservations</CardDescription>
                </CardHeader>
                <CardContent>
                    <Button
                        onClick={() => onApiCall(() => api.cleanupReservations(), 'Reservations cleaned')}
                        className="w-full"
                        variant="secondary"
                    >
                        Cleanup Reservations
                    </Button>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Generate Daily Report</CardTitle>
                    <CardDescription>Create comprehensive daily report</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-2">
                        <Label htmlFor="report-branch">Branch ID (Optional)</Label>
                        <Input
                            id="report-branch"
                            type="number"
                            placeholder="Branch ID"
                            value={branchId}
                            onChange={(e) => setBranchId(e.target.value)}
                        />
                        <Button
                            onClick={() => onApiCall(() => api.generateDailyReport(branchId ? parseInt(branchId) : undefined), 'Report generated')}
                            className="w-full"
                        >
                            Generate Report
                        </Button>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
};

export default AdminDashboard;
