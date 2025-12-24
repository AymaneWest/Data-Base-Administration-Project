import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardFooter, CardHeader } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { BookOpen } from "lucide-react";
import { Link } from "wouter";

interface BookCardProps {
  id: number;
  title: string;
  author: string;
  availability: "available" | "reserved" | "checked-out";
  genre?: string;
  imageUrl?: string;
}

export function BookCard({ id, title, author, availability, genre, imageUrl }: BookCardProps) {
  const statusColors = {
    available: "bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 shadow-sm shadow-emerald-500/20",
    reserved: "bg-amber-500/10 text-amber-500 hover:bg-amber-500/20 shadow-sm shadow-amber-500/20",
    "checked-out": "bg-rose-500/10 text-rose-500 hover:bg-rose-500/20 shadow-sm shadow-rose-500/20",
  };

  const statusLabels = {
    available: "Available",
    reserved: "Reserved",
    "checked-out": "Checked Out",
  };

  // Fallback to placeholder if no image or error loading
  const handleImageError = (e: React.SyntheticEvent<HTMLImageElement, Event>) => {
    e.currentTarget.src = "/covers/placeholder.jpg";
  };

  return (
    <Card className="flex flex-col h-full bg-card/50 backdrop-blur-sm border-white/5 hover:border-primary/50 transition-all duration-300 group overflow-hidden">
      <div className="relative aspect-[2/3] w-full overflow-hidden">
        {imageUrl ? (
          <img
            src={imageUrl}
            alt={title}
            className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-110"
            onError={handleImageError}
          />
        ) : (
          <div className="flex h-full w-full items-center justify-center bg-muted/30">
            <BookOpen className="h-16 w-16 text-muted-foreground/30" />
          </div>
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-background/90 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
        <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity duration-300 transform translate-y-2 group-hover:translate-y-0">
          <Badge className={`${statusColors[availability]} backdrop-blur-md border-0 uppercase text-[10px] tracking-wider font-bold`}>
            {statusLabels[availability]}
          </Badge>
        </div>
      </div>

      <CardHeader className="p-4 pb-2 space-y-1">
        {genre && (
          <span className="text-[10px] uppercase tracking-widest text-primary/80 font-semibold">
            {genre}
          </span>
        )}
        <h3 className="font-heading text-lg font-bold leading-tight group-hover:text-primary transition-colors line-clamp-2">
          {title}
        </h3>
        <p className="text-sm text-muted-foreground font-medium line-clamp-1">
          {author}
        </p>
      </CardHeader>

      <CardFooter className="p-4 mt-auto pt-2">
        <Link to={`/catalog/${id}`} className="w-full">
          <Button className="w-full bg-primary/10 hover:bg-primary/20 text-primary border-0 font-semibold" variant="outline">
            View Details
          </Button>
        </Link>
      </CardFooter>
    </Card>
  );
}