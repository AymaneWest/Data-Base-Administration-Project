import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Calendar, RefreshCw } from "lucide-react";
import { differenceInDays } from "date-fns";

export interface LoanCardProps {
  id: number;
  bookTitle: string;
  author: string;
  dueDate: Date;
  checkedOutDate: Date;
  canRenew?: boolean;
  onRenew?: () => void;
}

export function LoanCard({ id, bookTitle, author, dueDate, checkedOutDate, canRenew = true, onRenew }: LoanCardProps) {
  const today = new Date();
  const daysRemaining = differenceInDays(dueDate, today);
  const totalDays = differenceInDays(dueDate, checkedOutDate);
  const progress = Math.max(0, Math.min(100, ((totalDays - daysRemaining) / totalDays) * 100));
  
  const isOverdue = daysRemaining < 0;
  const isDueSoon = daysRemaining >= 0 && daysRemaining <= 3;

  return (
    <Card data-testid={`card-loan-${id}`}>
      <CardContent className="p-6">
        <div className="space-y-4">
          <div className="flex items-start justify-between gap-4">
            <div className="space-y-1 flex-1">
              <h3 className="font-semibold" data-testid={`text-loan-title-${id}`}>{bookTitle}</h3>
              <p className="text-sm text-muted-foreground">{author}</p>
            </div>
            {isOverdue && (
              <Badge variant="destructive">Overdue</Badge>
            )}
            {isDueSoon && !isOverdue && (
              <Badge className="bg-yellow-600 dark:bg-yellow-700">Due Soon</Badge>
            )}
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-2 text-muted-foreground">
                <Calendar className="h-4 w-4" />
                <span>Due: {dueDate.toLocaleDateString()}</span>
              </div>
              <span className={isOverdue ? "text-destructive font-medium" : "text-muted-foreground"}>
                {isOverdue ? `${Math.abs(daysRemaining)} days overdue` : `${daysRemaining} days left`}
              </span>
            </div>
            <Progress value={progress} className="h-2" />
          </div>

          {canRenew && !isOverdue && (
            <Button 
              variant="outline" 
              className="w-full" 
              onClick={() => {
                console.log(`Renewing loan ${id}`);
                onRenew?.();
              }}
              data-testid={`button-renew-${id}`}
            >
              <RefreshCw className="h-4 w-4 mr-2" />
              Renew Loan
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
}