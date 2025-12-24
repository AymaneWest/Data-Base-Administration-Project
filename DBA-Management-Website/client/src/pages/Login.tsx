import { PatronHeader } from "@/components/PatronHeader";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useAuth } from "@/lib/auth";
import { useState } from "react";
import { useLocation } from "wouter";
import { useToast } from "@/hooks/use-toast";

export default function Login() {
  const { login, isLoading } = useAuth();
  const [, setLocation] = useLocation();
  const { toast } = useToast();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();

    const result = await login(username, password);

    if (result.success) {
      // Get user roles from localStorage to determine redirect
      const rolesStr = localStorage.getItem('user_roles') || '[]';
      const roles = JSON.parse(rolesStr);

      toast({
        title: "Login Successful",
        description: `Welcome back! Redirecting to your dashboard...`,
      });

      // Role-based redirection
      // Admin roles (ROLE_SYS_ADMIN, ROLE_DIRECTOR) - can access ALL pages
      if (roles.some((r: string) => r.includes('ROLE_SYS_ADMIN') || r.includes('ROLE_DIRECTOR'))) {
        setLocation('/admin');
      }
      // Staff roles (ROLE_IT_SUPPORT, ROLE_CIRCULATION_CLERK, ROLE_CATALOGER) - can access staff + patron pages
      else if (roles.some((r: string) =>
        r.includes('ROLE_IT_SUPPORT') ||
        r.includes('ROLE_CIRCULATION_CLERK') ||
        r.includes('ROLE_CATALOGER')
      )) {
        setLocation('/staff');
      }
      // Patron role - access patron pages
      else if (roles.some((r: string) => r.includes('ROLE_PATRON'))) {
        setLocation('/');
      }
      // Fallback to home
      else {
        setLocation('/');
      }
    } else {
      toast({
        title: "Login Failed",
        description: result.error || "Invalid credentials",
        variant: "destructive",
      });
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <PatronHeader />

      <div className="container mx-auto px-4 py-16">
        <div className="max-w-md mx-auto">
          <Tabs defaultValue="login">
            <TabsList className="grid w-full grid-cols-1">
              <TabsTrigger value="login" data-testid="tab-login">Login</TabsTrigger>
            </TabsList>

            <TabsContent value="login">
              <Card>
                <CardHeader>
                  <CardTitle>Library System Login</CardTitle>
                  <CardDescription>
                    Access your account to manage library resources
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <form onSubmit={handleLogin} className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="username">Username</Label>
                      <Input
                        id="username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        placeholder="Enter your username"
                        required
                        disabled={isLoading}
                        data-testid="input-username"
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="password">Password</Label>
                      <Input
                        id="password"
                        type="password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder="Enter your password"
                        required
                        disabled={isLoading}
                        data-testid="input-password"
                      />
                    </div>
                    <Button
                      type="submit"
                      className="w-full"
                      disabled={isLoading}
                      data-testid="button-login"
                    >
                      {isLoading ? 'Logging in...' : 'Login'}
                    </Button>
                    <div className="text-center space-y-2">
                      <Button variant="ghost" className="text-sm" data-testid="link-forgot-password">
                        Forgot password?
                      </Button>
                      <p className="text-sm text-muted-foreground">
                        Don't have an account?{" "}
                        <Button variant="ghost" className="p-0 h-auto" data-testid="link-register">
                          Contact your administrator
                        </Button>
                      </p>
                    </div>
                  </form>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </div>
  );
}
