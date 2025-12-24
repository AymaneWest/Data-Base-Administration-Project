import { Switch, Route, Redirect } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { AuthProvider } from "@/lib/auth";
import { getAuthToken, getUserRoles } from "@/lib/auth-utils";
import NotFound from "@/pages/not-found";
import Home from "@/pages/Home";
import Catalog from "@/pages/Catalog";
import Branches from "@/pages/Branches";
import Login from "@/pages/Login";
import Account from "@/pages/Account";
import StaffDashboard from "@/pages/StaffDashboard";
import AdminDashboard from "@/pages/AdminDashboard";
import Circulation from "@/pages/staff/Circulation";
import Patrons from "@/pages/staff/Patrons";
import StaffCatalog from "@/pages/staff/Catalog";
import Reservations from "@/pages/staff/Reservations";
import Fines from "@/pages/staff/Fines";
import Reports from "@/pages/staff/Reports";
import { useLocation } from "wouter";
// In your routes file (e.g., App.tsx or routes.tsx)
import BookDetails from "@/pages/BookDetails";

// Add this route:
<Route path="/catalog/:materialId" component={BookDetails} />
// Protected Route Component
interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: string[];
}

function ProtectedRoute({ children, allowedRoles }: ProtectedRouteProps) {
  const [, setLocation] = useLocation();
  const token = getAuthToken();
  const userRoles = getUserRoles();

  if (!token) {
    return <Redirect to="/login" />;
  }

  if (allowedRoles && allowedRoles.length > 0) {
    // Convert everything to uppercase for comparison
    const userRolesUpper = userRoles.map((r: string) => r.toUpperCase());

    // Check if user has admin roles (can access everything)
    const hasAdminRole = userRolesUpper.some((role: string) =>
      role.includes('ROLE_SYS_ADMIN') || role.includes('ROLE_DIRECTOR')
    );

    // Check if user has at least one of the allowed roles
    const hasAllowedRole = userRolesUpper.some((role: string) =>
      allowedRoles.some(allowed => role.includes(allowed.toUpperCase()))
    );

    const hasPermission = hasAdminRole || hasAllowedRole;

    if (!hasPermission) {
      // Role-based redirect
      if (userRoles.some((r: string) => r.includes('ROLE_PATRON'))) {
        return <Redirect to="/" />;
      }
      if (userRoles.some((r: string) =>
        r.includes('ROLE_IT_SUPPORT') ||
        r.includes('ROLE_CIRCULATION_CLERK') ||
        r.includes('ROLE_CATALOGER')
      )) {
        return <Redirect to="/staff" />;
      }
      return <Redirect to="/login" />;
    }
  }

  return <>{children}</>;
}

function Router() {
  return (
    <Switch>
      <Route path="/login" component={Login} />
      <Route path="/" component={Home} />
      <Route path="/catalog" component={Catalog} />
      <Route path="/catalog/:materialId" component={BookDetails} /> 
      <Route path="/branches" component={Branches} />

      <Route path="/account">
        <ProtectedRoute>
          <Account />
        </ProtectedRoute>
      </Route>

      {/* Staff Routes */}
      <Route path="/staff">
        <ProtectedRoute allowedRoles={['ROLE_IT_SUPPORT', 'ROLE_CIRCULATION_CLERK', 'ROLE_CATALOGER']}>
          <StaffDashboard />
        </ProtectedRoute>
      </Route>

      <Route path="/staff/circulation">
        <ProtectedRoute allowedRoles={['ROLE_IT_SUPPORT', 'ROLE_CIRCULATION_CLERK', 'ROLE_CATALOGER']}>
          <Circulation />
        </ProtectedRoute>
      </Route>

      <Route path="/staff/patrons">
        <ProtectedRoute allowedRoles={['ROLE_IT_SUPPORT', 'ROLE_CIRCULATION_CLERK', 'ROLE_CATALOGER']}>
          <Patrons />
        </ProtectedRoute>
      </Route>

      <Route path="/staff/catalog">
        <ProtectedRoute allowedRoles={['ROLE_IT_SUPPORT', 'ROLE_CIRCULATION_CLERK', 'ROLE_CATALOGER']}>
          <StaffCatalog />
        </ProtectedRoute>
      </Route>

      <Route path="/staff/reservations">
        <ProtectedRoute allowedRoles={['ROLE_IT_SUPPORT', 'ROLE_CIRCULATION_CLERK', 'ROLE_CATALOGER']}>
          <Reservations />
        </ProtectedRoute>
      </Route>

      <Route path="/staff/fines">
        <ProtectedRoute allowedRoles={['ROLE_IT_SUPPORT', 'ROLE_CIRCULATION_CLERK', 'ROLE_CATALOGER']}>
          <Fines />
        </ProtectedRoute>
      </Route>

      <Route path="/staff/reports">
        <ProtectedRoute allowedRoles={['ROLE_IT_SUPPORT', 'ROLE_CIRCULATION_CLERK', 'ROLE_CATALOGER']}>
          <Reports />
        </ProtectedRoute>
      </Route>

      {/* Admin Route */}
      <Route path="/admin">
        <ProtectedRoute allowedRoles={['ROLE_SYS_ADMIN', 'ROLE_DIRECTOR']}>
          <AdminDashboard />
        </ProtectedRoute>
      </Route>

      <Route component={NotFound} />
    </Switch>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <AuthProvider>
          <Toaster />
          <Router />
        </AuthProvider>
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;