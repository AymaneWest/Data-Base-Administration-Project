import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Book } from "lucide-react";
import bookPlaceholder from "@assets/generated_images/book_cover_placeholder_047ab69e.png";

export interface BookCardProps {
  id: number;
  title: string;
  author: string;
  coverUrl?: string;
  availability: "available" | "reserved" | "checked-out";
  genre?: string;
  onClick?: () => void;
}

export function BookCard({ id, title, author, coverUrl, availability, genre, onClick }: BookCardProps) {
  const statusColors = {
    available: "bg-green-600 dark:bg-green-700",
    reserved: "bg-yellow-600 dark:bg-yellow-700",
    "checked-out": "bg-muted dark:bg-muted"
  };

  const statusLabels = {
    available: "Available",
    reserved: "Reserved",
    "checked-out": "Checked Out"
  };

  return (
    <Card 
      className="overflow-hidden hover-elevate active-elevate-2 cursor-pointer group transition-all" 
      onClick={onClick}
      data-testid={`card-book-${id}`}
    >
      <div className="aspect-[2/3] bg-muted relative overflow-hidden">
        {coverUrl ? (
          <img src={coverUrl} alt={title} className="w-full h-full object-cover" />
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-primary/10 to-primary/5">
            <img src={bookPlaceholder} alt={title} className="w-full h-full object-cover opacity-50" />
            <Book className="h-16 w-16 text-muted-foreground absolute" />
          </div>
        )}
        <Badge className={`absolute top-2 right-2 ${statusColors[availability]}`}>
          {statusLabels[availability]}
        </Badge>
      </div>
      <div className="p-4 space-y-2">
        <h3 className="font-semibold text-sm line-clamp-2 min-h-[2.5rem]" data-testid={`text-book-title-${id}`}>
          {title}
        </h3>
        <p className="text-sm text-muted-foreground line-clamp-1" data-testid={`text-book-author-${id}`}>
          {author}
        </p>
        {genre && (
          <Badge variant="secondary" className="text-xs">
            {genre}
          </Badge>
        )}
      </div>
    </Card>
  );
}