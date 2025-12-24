import { BookMarked, User } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "./ThemeToggle";
import { useAuth } from "@/lib/auth";
import { Link } from "wouter";

export function PatronHeader() {
  const { user, logout } = useAuth();

  return (
    <header className="sticky top-0 z-50 border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto px-4 h-16 flex items-center justify-between gap-4">
        <Link href="/">
          <a className="flex items-center gap-2 hover-elevate active-elevate-2 px-3 py-2 rounded-md" data-testid="link-home">
            <BookMarked className="h-6 w-6 text-primary" />
            <span className="font-semibold text-lg hidden sm:inline">City Library</span>
          </a>
        </Link>

        <nav className="hidden md:flex items-center gap-1">
          <Link href="/catalog">
            <a>
              <Button variant="ghost" data-testid="button-catalog">
                Catalog
              </Button>
            </a>
          </Link>
          <Link href="/branches">
            <a>
              <Button variant="ghost" data-testid="button-branches">
                Branches
              </Button>
            </a>
          </Link>
          {user && (
            <Link href="/account">
              <a>
                <Button variant="ghost" data-testid="button-account">
                  My Account
                </Button>
              </a>
            </Link>
          )}
        </nav>

        <div className="flex items-center gap-2">
          <ThemeToggle />
          {user ? (
            <div className="flex items-center gap-2">
              <Link href="/account">
                <a>
                  <Button variant="ghost" size="icon" data-testid="button-user-menu">
                    <User className="h-5 w-5" />
                  </Button>
                </a>
              </Link>
              <Button variant="outline" onClick={logout} data-testid="button-logout" className="hidden sm:flex">
                Logout
              </Button>
            </div>
          ) : (
            <Link href="/login">
              <a>
                <Button variant="default" data-testid="button-login">
                  Login
                </Button>
              </a>
            </Link>
          )}
        </div>
      </div>
    </header>
  );
}