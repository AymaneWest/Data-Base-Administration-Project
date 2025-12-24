import { LayoutDashboard, BookOpen, Users, FileText, Settings, Package, DollarSign, TrendingUp, LogOut } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useLocation } from "wouter";
import { Link } from "wouter";
import { useAuth } from "@/lib/auth";

const menuItems = [
  { icon: LayoutDashboard, label: "Dashboard", path: "/staff" },
  { icon: BookOpen, label: "Circulation", path: "/staff/circulation" },
  { icon: Users, label: "Patrons", path: "/staff/patrons" },
  { icon: Package, label: "Catalog", path: "/staff/catalog" },
  { icon: FileText, label: "Reservations", path: "/staff/reservations" },
  { icon: DollarSign, label: "Fines", path: "/staff/fines" },
  { icon: TrendingUp, label: "Reports", path: "/staff/reports" },
  { icon: Settings, label: "Admin", path: "/admin" },
];

export function StaffSidebar() {
  const [location, setLocation] = useLocation();
  const { user, logout } = useAuth();

  const handleLogout = async () => {
    await logout();
    setLocation('/login');
  };

  return (
    <div className="w-64 border-r bg-sidebar h-screen sticky top-0 flex flex-col">
      <div className="p-6 border-b">
        <h2 className="text-xl font-semibold">Staff Portal</h2>
        <p className="text-sm text-muted-foreground">Library Management</p>
      </div>

      <nav className="flex-1 p-4 space-y-1">
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = location === item.path || location.startsWith(item.path + '/');

          return (
            <Link key={item.path} href={item.path}>
              <a>
                <Button
                  variant={isActive ? "default" : "ghost"}
                  className="w-full justify-start gap-3"
                  data-testid={`button-nav-${item.label.toLowerCase()}`}
                >
                  <Icon className="h-5 w-5" />
                  {item.label}
                </Button>
              </a>
            </Link>
          );
        })}
      </nav>

      <div className="p-4 border-t space-y-2">
        <div className="text-xs text-muted-foreground space-y-1">
          <p>Logged in as</p>
          <p className="font-medium text-foreground">{user?.username || 'Staff Member'}</p>
        </div>
        <Button
          variant="outline"
          className="w-full justify-start gap-2"
          onClick={handleLogout}
          size="sm"
        >
          <LogOut className="h-4 w-4" />
          Logout
        </Button>
      </div>
    </div>
  );
}
