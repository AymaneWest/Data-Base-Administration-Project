import { drizzle } from 'drizzle-orm/node-postgres';
import pkg from 'pg';
const { Pool } = pkg;
import * as schema from '@shared/schema';
import { eq, and, desc, sql, count, gte, lte, or, ilike, isNull } from 'drizzle-orm';
import bcrypt from 'bcryptjs';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

export const db = drizzle(pool, { schema });

export class DatabaseStorage {
  // ============================================================================
  // USERS & AUTH
  // ============================================================================
  
  async getUserById(userId: number) {
    const [user] = await db.select().from(schema.users).where(eq(schema.users.userId, userId));
    return user;
  }

  async getUserByUsername(username: string) {
    const [user] = await db.select().from(schema.users).where(eq(schema.users.username, username));
    return user;
  }

  async getUserByEmail(email: string) {
    const [user] = await db.select().from(schema.users).where(eq(schema.users.email, email));
    return user;
  }

  async createUser(userData: typeof schema.insertUserSchema._type) {
    const hashedPassword = await bcrypt.hash(userData.passwordHash, 10);
    const [user] = await db.insert(schema.users).values({
      ...userData,
      passwordHash: hashedPassword,
    }).returning();
    return user;
  }

  async updateUserLastLogin(userId: number) {
    await db.update(schema.users)
      .set({ lastLogin: new Date() })
      .where(eq(schema.users.userId, userId));
  }

  async verifyPassword(passwordHash: string, password: string) {
    return bcrypt.compare(password, passwordHash);
  }

  // ============================================================================
  // ROLES & PERMISSIONS
  // ============================================================================

  async getRoleByCode(roleCode: string) {
    const [role] = await db.select().from(schema.roles).where(eq(schema.roles.roleCode, roleCode));
    return role;
  }

  async getUserRoles(userId: number) {
    const results = await db
      .select({ role: schema.roles })
      .from(schema.userRoles)
      .innerJoin(schema.roles, eq(schema.userRoles.roleId, schema.roles.roleId))
      .where(and(
        eq(schema.userRoles.userId, userId),
        eq(schema.userRoles.isActive, true)
      ));
    return results.map(r => r.role);
  }

  async getUserPermissions(userId: number) {
    const results = await db
      .select({ permission: schema.permissions })
      .from(schema.userRoles)
      .innerJoin(schema.rolePermissions, eq(schema.userRoles.roleId, schema.rolePermissions.roleId))
      .innerJoin(schema.permissions, eq(schema.rolePermissions.permissionId, schema.permissions.permissionId))
      .where(and(
        eq(schema.userRoles.userId, userId),
        eq(schema.userRoles.isActive, true),
        eq(schema.permissions.isActive, true)
      ));
    return results.map(r => r.permission);
  }

  async assignRoleToUser(userId: number, roleId: number, assignedBy?: number) {
    await db.insert(schema.userRoles).values({
      userId,
      roleId,
      assignedByUserId: assignedBy,
    }).onConflictDoNothing();
  }

  // ============================================================================
  // MATERIALS & CATALOG
  // ============================================================================

  async getMaterials(filters?: { search?: string; genreId?: number; availability?: string; limit?: number; offset?: number }) {
    let query = db.select({
      material: schema.materials,
      availableCopies: sql<number>`count(distinct case when ${schema.copies.copyStatus} = 'Available' then ${schema.copies.copyId} end)`.as('available_copies'),
    })
      .from(schema.materials)
      .leftJoin(schema.copies, eq(schema.materials.materialId, schema.copies.materialId))
      .groupBy(schema.materials.materialId)
      .$dynamic();

    if (filters?.search) {
      query = query.where(
        or(
          ilike(schema.materials.title, `%${filters.search}%`),
          ilike(schema.materials.isbn, `%${filters.search}%`)
        )
      );
    }

    if (filters?.genreId) {
      query = query.innerJoin(schema.materialGenres, eq(schema.materials.materialId, schema.materialGenres.materialId))
        .where(eq(schema.materialGenres.genreId, filters.genreId));
    }

    if (filters?.limit) {
      query = query.limit(filters.limit);
    }

    if (filters?.offset) {
      query = query.offset(filters.offset);
    }

    const results = await query;
    
    // Fetch authors and genres for each material
    const materials = await Promise.all(results.map(async (r) => {
      const authors = await this.getMaterialAuthors(r.material.materialId);
      const genres = await this.getMaterialGenres(r.material.materialId);
      return {
        ...r.material,
        authors,
        genres,
        availableCopies: Number(r.availableCopies) || 0,
      };
    }));

    return materials;
  }

  async getMaterialById(materialId: number) {
    const [material] = await db.select().from(schema.materials).where(eq(schema.materials.materialId, materialId));
    return material;
  }

  async getMaterialAuthors(materialId: number) {
    const results = await db
      .select({ author: schema.authors })
      .from(schema.materialAuthors)
      .innerJoin(schema.authors, eq(schema.materialAuthors.authorId, schema.authors.authorId))
      .where(eq(schema.materialAuthors.materialId, materialId))
      .orderBy(schema.materialAuthors.authorOrder);
    return results.map(r => r.author);
  }

  async getMaterialGenres(materialId: number) {
    const results = await db
      .select({ genre: schema.genres })
      .from(schema.materialGenres)
      .innerJoin(schema.genres, eq(schema.materialGenres.genreId, schema.genres.genreId))
      .where(eq(schema.materialGenres.materialId, materialId));
    return results.map(r => r.genre);
  }

  async createMaterial(materialData: typeof schema.insertMaterialSchema._type) {
    const [material] = await db.insert(schema.materials).values(materialData).returning();
    return material;
  }

  async updateMaterial(materialId: number, materialData: Partial<typeof schema.insertMaterialSchema._type>) {
    await db.update(schema.materials).set(materialData).where(eq(schema.materials.materialId, materialId));
  }

  // ============================================================================
  // AUTHORS, PUBLISHERS, GENRES
  // ============================================================================

  async getAuthors() {
    return db.select().from(schema.authors).orderBy(schema.authors.lastName, schema.authors.firstName);
  }

  async getPublishers() {
    return db.select().from(schema.publishers).orderBy(schema.publishers.publisherName);
  }

  async getGenres() {
    return db.select().from(schema.genres).orderBy(schema.genres.genreName);
  }

  async createAuthor(authorData: typeof schema.insertAuthorSchema._type) {
    const [author] = await db.insert(schema.authors).values(authorData).returning();
    return author;
  }

  async createPublisher(publisherData: typeof schema.insertPublisherSchema._type) {
    const [publisher] = await db.insert(schema.publishers).values(publisherData).returning();
    return publisher;
  }

  async createGenre(genreData: typeof schema.insertGenreSchema._type) {
    const [genre] = await db.insert(schema.genres).values(genreData).returning();
    return genre;
  }

  async addMaterialAuthor(materialId: number, authorId: number, order: number = 1) {
    await db.insert(schema.materialAuthors).values({ materialId, authorId, authorOrder: order });
  }

  async addMaterialGenre(materialId: number, genreId: number) {
    await db.insert(schema.materialGenres).values({ materialId, genreId });
  }

  // ============================================================================
  // COPIES
  // ============================================================================

  async getCopiesByMaterial(materialId: number) {
    return db.select().from(schema.copies).where(eq(schema.copies.materialId, materialId));
  }

  async getCopyById(copyId: number) {
    const [copy] = await db.select().from(schema.copies).where(eq(schema.copies.copyId, copyId));
    return copy;
  }

  async createCopy(copyData: typeof schema.insertCopySchema._type) {
    const [copy] = await db.insert(schema.copies).values(copyData).returning();
    return copy;
  }

  async updateCopyStatus(copyId: number, status: string) {
    await db.update(schema.copies).set({ copyStatus: status }).where(eq(schema.copies.copyId, copyId));
  }

  // ============================================================================
  // PATRONS
  // ============================================================================

  async getPatronById(patronId: number) {
    const [patron] = await db.select().from(schema.patrons).where(eq(schema.patrons.patronId, patronId));
    return patron;
  }

  async getPatronByUserId(userId: number) {
    const [patron] = await db.select().from(schema.patrons).where(eq(schema.patrons.userId, userId));
    return patron;
  }

  async getPatronByCardNumber(cardNumber: string) {
    const [patron] = await db.select().from(schema.patrons).where(eq(schema.patrons.cardNumber, cardNumber));
    return patron;
  }

  async searchPatrons(query: string) {
    return db.select().from(schema.patrons).where(
      or(
        ilike(schema.patrons.firstName, `%${query}%`),
        ilike(schema.patrons.lastName, `%${query}%`),
        ilike(schema.patrons.email, `%${query}%`),
        ilike(schema.patrons.cardNumber, `%${query}%`)
      )
    ).limit(50);
  }

  async createPatron(patronData: typeof schema.insertPatronSchema._type) {
    const [patron] = await db.insert(schema.patrons).values(patronData).returning();
    return patron;
  }

  async updatePatron(patronId: number, patronData: Partial<typeof schema.insertPatronSchema._type>) {
    await db.update(schema.patrons).set(patronData).where(eq(schema.patrons.patronId, patronId));
  }

  // ============================================================================
  // LOANS
  // ============================================================================

  async getActiveLoans(patronId: number) {
    const results = await db
      .select({
        loan: schema.loans,
        copy: schema.copies,
        material: schema.materials,
      })
      .from(schema.loans)
      .innerJoin(schema.copies, eq(schema.loans.copyId, schema.copies.copyId))
      .innerJoin(schema.materials, eq(schema.copies.materialId, schema.materials.materialId))
      .where(and(
        eq(schema.loans.patronId, patronId),
        eq(schema.loans.loanStatus, 'Active')
      ))
      .orderBy(desc(schema.loans.checkoutDate));
    
    return results.map(r => ({
      ...r.loan,
      copy: r.copy,
      material: r.material,
    }));
  }

  async getLoanHistory(patronId: number) {
    const results = await db
      .select({
        loan: schema.loans,
        material: schema.materials,
      })
      .from(schema.loans)
      .innerJoin(schema.copies, eq(schema.loans.copyId, schema.copies.copyId))
      .innerJoin(schema.materials, eq(schema.copies.materialId, schema.materials.materialId))
      .where(eq(schema.loans.patronId, patronId))
      .orderBy(desc(schema.loans.checkoutDate))
      .limit(100);
    
    return results.map(r => ({
      ...r.loan,
      material: r.material,
    }));
  }

  async createLoan(loanData: typeof schema.insertLoanSchema._type) {
    const [loan] = await db.insert(schema.loans).values(loanData).returning();
    // Update copy status to Checked Out
    await this.updateCopyStatus(loanData.copyId, 'Checked Out');
    return loan;
  }

  async returnLoan(loanId: number, staffId: number) {
    const [loan] = await db.select().from(schema.loans).where(eq(schema.loans.loanId, loanId));
    if (loan) {
      await db.update(schema.loans).set({
        returnDate: new Date(),
        returnedTo: staffId,
        loanStatus: 'Returned',
      }).where(eq(schema.loans.loanId, loanId));
      
      // Update copy status back to Available
      await this.updateCopyStatus(loan.copyId, 'Available');
      
      // Calculate fine if overdue
      const daysOverdue = Math.floor((new Date().getTime() - loan.dueDate.getTime()) / (1000 * 60 * 60 * 24));
      if (daysOverdue > 0) {
        const fineAmount = daysOverdue * 1.0; // $1 per day
        await this.createFine({
          loanId: loanId,
          patronId: loan.patronId,
          fineAmount: fineAmount.toString(),
          fineReason: `Late return (${daysOverdue} days overdue)`,
        });
      }
    }
  }

  async renewLoan(loanId: number) {
    const [loan] = await db.select().from(schema.loans).where(eq(schema.loans.loanId, loanId));
    if (loan && loan.renewalCount < 2) {
      const newDueDate = new Date(loan.dueDate);
      newDueDate.setDate(newDueDate.getDate() + 14);
      
      await db.update(schema.loans).set({
        dueDate: newDueDate,
        renewalCount: loan.renewalCount + 1,
      }).where(eq(schema.loans.loanId, loanId));
    }
  }

  async getOverdueLoans(branchId?: number) {
    let query = db
      .select({
        loan: schema.loans,
        patron: schema.patrons,
        material: schema.materials,
      })
      .from(schema.loans)
      .innerJoin(schema.patrons, eq(schema.loans.patronId, schema.patrons.patronId))
      .innerJoin(schema.copies, eq(schema.loans.copyId, schema.copies.copyId))
      .innerJoin(schema.materials, eq(schema.copies.materialId, schema.materials.materialId))
      .where(and(
        eq(schema.loans.loanStatus, 'Active'),
        lte(schema.loans.dueDate, new Date())
      ))
      .$dynamic();

    if (branchId) {
      query = query.where(eq(schema.copies.branchId, branchId));
    }

    const results = await query.orderBy(schema.loans.dueDate);
    
    return results.map(r => ({
      ...r.loan,
      patron: r.patron,
      material: r.material,
    }));
  }

  // ============================================================================
  // RESERVATIONS
  // ============================================================================

  async getPatronReservations(patronId: number) {
    const results = await db
      .select({
        reservation: schema.reservations,
        material: schema.materials,
      })
      .from(schema.reservations)
      .innerJoin(schema.materials, eq(schema.reservations.materialId, schema.materials.materialId))
      .where(and(
        eq(schema.reservations.patronId, patronId),
        or(
          eq(schema.reservations.reservationStatus, 'Pending'),
          eq(schema.reservations.reservationStatus, 'Ready')
        )
      ))
      .orderBy(desc(schema.reservations.reservationDate));
    
    return results.map(r => ({
      ...r.reservation,
      material: r.material,
    }));
  }

  async createReservation(reservationData: typeof schema.insertReservationSchema._type) {
    // Get current queue position
    const [{ count: queueCount }] = await db
      .select({ count: count() })
      .from(schema.reservations)
      .where(and(
        eq(schema.reservations.materialId, reservationData.materialId),
        eq(schema.reservations.reservationStatus, 'Pending')
      ));
    
    const [reservation] = await db.insert(schema.reservations).values({
      ...reservationData,
      queuePosition: queueCount + 1,
    }).returning();
    
    return reservation;
  }

  async getPendingReservations(materialId?: number) {
    let query = db
      .select({
        reservation: schema.reservations,
        patron: schema.patrons,
      })
      .from(schema.reservations)
      .innerJoin(schema.patrons, eq(schema.reservations.patronId, schema.patrons.patronId))
      .where(eq(schema.reservations.reservationStatus, 'Pending'))
      .$dynamic();

    if (materialId) {
      query = query.where(eq(schema.reservations.materialId, materialId));
    }

    const results = await query.orderBy(schema.reservations.queuePosition);
    
    return results.map(r => ({
      ...r.reservation,
      patron: r.patron,
    }));
  }

  async fulfillReservation(reservationId: number) {
    await db.update(schema.reservations).set({
      reservationStatus: 'Fulfilled',
      fulfilledDate: new Date(),
    }).where(eq(schema.reservations.reservationId, reservationId));
  }

  // ============================================================================
  // FINES
  // ============================================================================

  async getPatronFines(patronId: number) {
    return db.select().from(schema.fines)
      .where(eq(schema.fines.patronId, patronId))
      .orderBy(desc(schema.fines.fineDate));
  }

  async createFine(fineData: typeof schema.insertFineSchema._type) {
    const [fine] = await db.insert(schema.fines).values(fineData).returning();
    
    // Update patron's total fines owed
    const fines = await this.getPatronFines(fineData.patronId);
    const totalOwed = fines
      .filter(f => f.fineStatus === 'Pending')
      .reduce((sum, f) => sum + Number(f.fineAmount), 0);
    
    await db.update(schema.patrons)
      .set({ totalFinesOwed: totalOwed.toString() })
      .where(eq(schema.patrons.patronId, fineData.patronId));
    
    return fine;
  }

  async payFine(fineId: number, paymentMethod: string) {
    const [fine] = await db.select().from(schema.fines).where(eq(schema.fines.fineId, fineId));
    if (fine) {
      await db.update(schema.fines).set({
        fineStatus: 'Paid',
        paidDate: new Date(),
        paymentMethod,
      }).where(eq(schema.fines.fineId, fineId));
      
      // Update patron's total fines owed
      const fines = await this.getPatronFines(fine.patronId);
      const totalOwed = fines
        .filter(f => f.fineStatus === 'Pending' && f.fineId !== fineId)
        .reduce((sum, f) => sum + Number(f.fineAmount), 0);
      
      await db.update(schema.patrons)
        .set({ totalFinesOwed: totalOwed.toString() })
        .where(eq(schema.patrons.patronId, fine.patronId));
    }
  }

  async waiveFine(fineId: number, staffId: number, reason: string) {
    const [fine] = await db.select().from(schema.fines).where(eq(schema.fines.fineId, fineId));
    if (fine) {
      await db.update(schema.fines).set({
        fineStatus: 'Waived',
        waivedBy: staffId,
        waivedReason: reason,
      }).where(eq(schema.fines.fineId, fineId));
      
      // Update patron's total fines owed
      const fines = await this.getPatronFines(fine.patronId);
      const totalOwed = fines
        .filter(f => f.fineStatus === 'Pending' && f.fineId !== fineId)
        .reduce((sum, f) => sum + Number(f.fineAmount), 0);
      
      await db.update(schema.patrons)
        .set({ totalFinesOwed: totalOwed.toString() })
        .where(eq(schema.patrons.patronId, fine.patronId));
    }
  }

  // ============================================================================
  // BRANCHES & LIBRARIES
  // ============================================================================

  async getBranches() {
    return db.select().from(schema.branches).orderBy(schema.branches.branchName);
  }

  async getBranchById(branchId: number) {
    const [branch] = await db.select().from(schema.branches).where(eq(schema.branches.branchId, branchId));
    return branch;
  }

  async getLibraries() {
    return db.select().from(schema.libraries).orderBy(schema.libraries.libraryName);
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  async getDashboardStats(branchId?: number) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let checkoutQuery = db
      .select({ count: count() })
      .from(schema.loans)
      .where(gte(schema.loans.checkoutDate, today))
      .$dynamic();

    let returnQuery = db
      .select({ count: count() })
      .from(schema.loans)
      .where(and(
        gte(schema.loans.returnDate, today),
        eq(schema.loans.loanStatus, 'Returned')
      ))
      .$dynamic();

    let overdueQuery = db
      .select({ count: count() })
      .from(schema.loans)
      .where(and(
        eq(schema.loans.loanStatus, 'Active'),
        lte(schema.loans.dueDate, new Date())
      ))
      .$dynamic();

    if (branchId) {
      checkoutQuery = checkoutQuery
        .innerJoin(schema.copies, eq(schema.loans.copyId, schema.copies.copyId))
        .where(eq(schema.copies.branchId, branchId));
        
      returnQuery = returnQuery
        .innerJoin(schema.copies, eq(schema.loans.copyId, schema.copies.copyId))
        .where(eq(schema.copies.branchId, branchId));
        
      overdueQuery = overdueQuery
        .innerJoin(schema.copies, eq(schema.loans.copyId, schema.copies.copyId))
        .where(eq(schema.copies.branchId, branchId));
    }

    const [checkouts] = await checkoutQuery;
    const [returns] = await returnQuery;
    const [overdue] = await overdueQuery;
    const [reservations] = await db
      .select({ count: count() })
      .from(schema.reservations)
      .where(eq(schema.reservations.reservationStatus, 'Pending'));

    return {
      todayCheckouts: checkouts.count,
      todayReturns: returns.count,
      overdueItems: overdue.count,
      activeReservations: reservations.count,
    };
  }
}

export const storage = new DatabaseStorage();