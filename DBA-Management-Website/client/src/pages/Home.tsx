import { PatronHeader } from "@/components/PatronHeader";
import { SearchBar } from "@/components/SearchBar";
import { BookCard } from "@/components/BookCard";
import { Button } from "@/components/ui/button";
import { BookOpen, Clock, Users, MapPin } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import heroImage from "@assets/generated_images/library_hero_interior_c7e392c3.png";
import { Link } from "wouter";
import { useEffect, useState } from "react";
import * as api from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { useToast } from "@/hooks/use-toast";

interface FeaturedBook {
  material_id?: number;
  id?: number;
  title: string;
  authors?: string;
  author?: string;
  availability?: "available" | "reserved" | "checked-out";
  genre?: string;
  genres?: string;
  available_copies?: number;
}

interface DashboardStats {
  total_materials?: number;
  total_patrons?: number;
  active_patrons?: number;
  total_branches?: number;
  available_copies?: number;
}

export default function Home() {
  const { user } = useAuth();
  const { toast } = useToast();
  const [featuredBooks, setFeaturedBooks] = useState<FeaturedBook[]>([]);
  const [stats, setStats] = useState<DashboardStats>({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadHomeData();
  }, [user]);

  const loadHomeData = async () => {
    setLoading(true);
    try {
      // Load public stats (available to everyone)
      try {
        const publicStatsResponse = await api.getPublicStats();
        const publicStats = publicStatsResponse.data || {};
        setStats({
          total_materials: publicStats.total_materials || 0,
          total_patrons: publicStats.active_patrons || 0,
          active_patrons: publicStats.active_patrons || 0,
          total_branches: publicStats.total_branches || 0,
          available_copies: publicStats.available_copies || 0,
        });
      } catch (error) {
        console.error("Failed to load public stats:", error);
        // Set default values on error
        setStats({
          total_materials: 0,
          total_patrons: 0,
          active_patrons: 0,
          total_branches: 0,
          available_copies: 0,
        });
      }

      // Load featured books (popular materials) - requires auth
      if (user) {
        try {
          const popularResponse = await api.getPopularMaterials(4);
          const books = (popularResponse.data || []).map((book: any) => ({
            id: book.material_id || book.id,
            material_id: book.material_id || book.id,
            title: book.title || "",
            author: book.authors || book.author || "Unknown Author",
            authors: book.authors || book.author || "Unknown Author",
            availability: (book.available_copies > 0 ? "available" : "checked-out") as "available" | "reserved" | "checked-out",
            genre: book.genres || book.genre || "",
            genres: book.genres || book.genre || "",
            available_copies: book.available_copies || 0,
          }));
          setFeaturedBooks(books);
        } catch (error) {
          console.error("Failed to load popular books:", error);
        }
      }
    } catch (error: any) {
      console.error("Failed to load home data:", error);
      toast({
        title: "Error",
        description: "Failed to load some data. Please try again later.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const displayStats = [
    { icon: BookOpen, label: "Books Available", value: loading ? "Loading..." : (stats.available_copies ? `${stats.available_copies.toLocaleString()}+` : "0") },
    { icon: Users, label: "Active Members", value: loading ? "Loading..." : (stats.active_patrons ? `${stats.active_patrons.toLocaleString()}+` : "0") },
    { icon: MapPin, label: "Branches", value: loading ? "Loading..." : (stats.total_branches ? `${stats.total_branches}` : "0") },
    { icon: Clock, label: "Open Daily", value: "8AM-8PM" },
  ];
  return (
    <div className="min-h-screen bg-background">
      <PatronHeader />
      
      <div 
        className="relative h-[500px] flex items-center justify-center bg-cover bg-center"
        style={{
          backgroundImage: `linear-gradient(to bottom, rgba(0,0,0,0.5), rgba(0,0,0,0.7)), url(${heroImage})`
        }}
      >
        <div className="container mx-auto px-4 text-center space-y-6 relative z-10">
          <h1 className="text-4xl md:text-6xl font-bold text-white">
            Discover Your Next Great Read
          </h1>
          <p className="text-xl text-white/90 max-w-2xl mx-auto">
            Browse thousands of books, manage your loans, and explore our collection
          </p>
          <div className="max-w-2xl mx-auto">
            <SearchBar placeholder="Search books, authors, ISBN..." />
          </div>
          <div className="flex gap-4 justify-center flex-wrap">
            <Link href="/catalog">
              <a>
                <Button size="lg" variant="default" data-testid="button-browse-catalog">
                  Browse Catalog
                </Button>
              </a>
            </Link>
            <Link href="/branches">
              <a>
                <Button size="lg" variant="outline" className="bg-white/10 backdrop-blur border-white/20 text-white hover:bg-white/20" data-testid="button-find-branch">
                  Find a Branch
                </Button>
              </a>
            </Link>
          </div>
        </div>
      </div>

      <div className="container mx-auto px-4 py-12">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-16">
          {displayStats.map((stat, idx) => {
            const Icon = stat.icon;
            return (
              <Card key={idx} data-testid={`card-stat-${idx}`}>
                <CardContent className="p-6 text-center space-y-2">
                  <div className="h-12 w-12 rounded-md bg-primary/10 flex items-center justify-center mx-auto">
                    <Icon className="h-6 w-6 text-primary" />
                  </div>
                  <p className="text-2xl font-bold">{stat.value}</p>
                  <p className="text-sm text-muted-foreground">{stat.label}</p>
                </CardContent>
              </Card>
            );
          })}
        </div>

        <div className="space-y-8">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-bold">Featured New Releases</h2>
              <p className="text-muted-foreground mt-1">Popular books added this month</p>
            </div>
            <Link href="/catalog">
              <a>
                <Button variant="ghost" data-testid="button-view-all">
                  View All →
                </Button>
              </a>
            </Link>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {loading ? (
              <div className="col-span-full text-center py-8 text-muted-foreground">
                Loading featured books...
              </div>
            ) : featuredBooks.length > 0 ? (
              featuredBooks.map((book) => (
                <BookCard 
                  key={book.id || book.material_id || Math.random()} 
                  id={book.id || book.material_id || 0}
                  title={book.title}
                  author={book.author || book.authors || "Unknown Author"}
                  availability={book.availability || "available"}
                  genre={book.genre || book.genres}
                />
              ))
            ) : (
              <div className="col-span-full text-center py-8 text-muted-foreground">
                No featured books available at the moment.
              </div>
            )}
          </div>
        </div>

        <div className="mt-16 grid md:grid-cols-3 gap-8">
          <Card>
            <CardContent className="p-8 text-center space-y-4">
              <div className="h-16 w-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto">
                <BookOpen className="h-8 w-8 text-primary" />
              </div>
              <h3 className="text-xl font-semibold">Browse & Borrow</h3>
              <p className="text-muted-foreground">
                Access our extensive collection of books, audiobooks, and digital materials
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-8 text-center space-y-4">
              <div className="h-16 w-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto">
                <Clock className="h-8 w-8 text-primary" />
              </div>
              <h3 className="text-xl font-semibold">Reserve & Renew</h3>
              <p className="text-muted-foreground">
                Place holds on popular titles and manage your loans online
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-8 text-center space-y-4">
              <div className="h-16 w-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto">
                <MapPin className="h-8 w-8 text-primary" />
              </div>
              <h3 className="text-xl font-semibold">Multiple Locations</h3>
              <p className="text-muted-foreground">
                Visit any of our 5 branches across the city at your convenience
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}