import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { useState, useEffect, useRef } from "react";
import { Card, CardContent } from "@/components/ui/card";
import * as api from "@/lib/api";
import { useAuth } from "@/lib/auth";

export interface SearchBarProps {
  placeholder?: string;
  onSearch?: (query: string) => void;
  className?: string;
  showSuggestions?: boolean;
}

interface Suggestion {
  type: string;
  suggestion: string;
  material_id?: number;
}

export function SearchBar({ placeholder = "Search books, authors, ISBN...", onSearch, className, showSuggestions = true }: SearchBarProps) {
  const { user } = useAuth();
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
  const [showSuggestionsList, setShowSuggestionsList] = useState(false);
  const [loading, setLoading] = useState(false);
  const searchRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setShowSuggestionsList(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  useEffect(() => {
    if (query.length >= 2 && showSuggestions && user) {
      const timeoutId = setTimeout(async () => {
        setLoading(true);
        try {
          const response = await api.getSearchSuggestions(query, 8);
          setSuggestions(response.data || []);
          setShowSuggestionsList(true);
        } catch (error) {
          console.error("Failed to load suggestions:", error);
          setSuggestions([]);
        } finally {
          setLoading(false);
        }
      }, 300); // Debounce for 300ms

      return () => clearTimeout(timeoutId);
    } else {
      setSuggestions([]);
      setShowSuggestionsList(false);
    }
  }, [query, showSuggestions, user]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSearch?.(query);
    setShowSuggestionsList(false);
  };

  const handleSuggestionClick = (suggestion: string) => {
    setQuery(suggestion);
    setShowSuggestionsList(false);
    onSearch?.(suggestion);
  };

  return (
    <div ref={searchRef} className={`relative ${className}`}>
      <form onSubmit={handleSubmit}>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
          <Input
            type="search"
            placeholder={placeholder}
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onFocus={() => {
              if (suggestions.length > 0) {
                setShowSuggestionsList(true);
              }
            }}
            className="pl-10 h-12"
            data-testid="input-search"
          />
        </div>
      </form>

      {showSuggestionsList && (suggestions.length > 0 || loading) && (
        <Card className="absolute z-50 w-full mt-2 max-h-80 overflow-y-auto">
          <CardContent className="p-2">
            {loading ? (
              <div className="p-2 text-sm text-muted-foreground">Loading suggestions...</div>
            ) : (
              <div className="space-y-1">
                {suggestions.map((suggestion, index) => (
                  <div
                    key={index}
                    onClick={() => handleSuggestionClick(suggestion.suggestion)}
                    className="p-2 hover:bg-muted rounded-md cursor-pointer transition-colors"
                  >
                    <div className="flex items-center gap-2">
                      <Search className="h-4 w-4 text-muted-foreground" />
                      <div className="flex-1">
                        <p className="text-sm font-medium">{suggestion.suggestion}</p>
                        <p className="text-xs text-muted-foreground capitalize">{suggestion.type}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  );
}
