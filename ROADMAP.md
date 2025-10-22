# Renja Management - Product Roadmap

## Overview
This document outlines the planned features and improvements for the Renja Management application, a Flutter-based monitoring and evaluation (monev) system using the Hijriah (Islamic) calendar.

---

## The Story Behind
- Aplikasi ini dibuat atas dasar banyak nya temuan di lapangan menyangkut ketidak sinkron-an data seperti pelaporan, keterlambatan penyerahan renja dari atas ke bawah, dll.
- implementasi tahap 1 adalah membuat fitur yang mudah dilakukan dan tidak berdampak terlalu besar seperti Renja dan Monev.
  - Beberapa temuan dilapangan menyangkut renja seperti pembuatan renja di bawah sudah ada lebih dahulu sebelum di atas, ketika renja diatas turun kemudian ada bentrok dengan renja di bawah, maka petugas dilapang akan melakukan rescheduling dimana akan berdampak ke efisiensi waktu dan tenaga yang sudah disiapkan di awal.
  - Untuk monev, di asia dan central memiliki format berbeda dan cara penyampaian yang berbeda pula, terlebih di central menggunakan google form dimana itu adalah aplikasi external yang kita tidak tahu dibelakang nya ada apa dan ada siapa, sehingga dipandang lebih riskan terhadap kebocoran informasi.
- tahap selanjutnya aplikasi ini adalah dabes lengkap, sehingga antar satu bidang dengan yang lain nya memiliki data yang sinkron dan terpusat, serta mudah untuk diakses oleh petugas di lapangan. sehingga meminimalisir kesalahan/ketidak samaan dalam penyampaian laporan.
- aplikasi ini memiliki fitur export ke excel sehingga menjamin data di aplikasi dapat juga dimunculkan dengan cara yang sudah ada selama ini.  

## Phase 1: Authentication & Authorization

### 1.1 Login Authorization System
- **Status**: Planned
- **Description**: Implement user authentication and authorization system
- **Features**:
  - User login with email/username and password
  - User registration/signup flow
  - Password reset functionality
  - Session management
  - Role-based access control (RBAC)
    - Admin: Full access to all features and user management
    - Manager: Access to monev data and reporting
    - User: Limited access to assigned shafs/units
  - JWT token-based authentication
  - Secure token storage on device
  - Auto-logout on token expiration
  - Login state persistence

### 1.2 User Management
- **Status**: Planned
- **Description**: Backend user management features
- **Features**:
  - User profile management
  - User role assignment
  - User deactivation/deletion
  - Activity logging for audit trail

---

## Phase 2: Offline-First Architecture with Online Sync

### 2.1 Offline-First Approach
- **Status**: Planned
- **Description**: Enable full app functionality without internet connection
- **Features**:
  - All data stored locally in SQLite database
  - Complete monev form functionality offline
  - Data entry and editing without network
  - Local data persistence across app sessions
  - Conflict resolution strategy for offline changes

### 2.2 Online Synchronization
- **Status**: Planned
- **Description**: Sync local data with backend server when online
- **Features**:
  - Automatic sync detection (online/offline status)
  - Background sync when connection is restored
  - Sync queue for pending changes
  - Conflict resolution:
    - Last-write-wins strategy
    - User notification on conflicts
    - Manual conflict resolution UI
  - Incremental sync (only changed data)
  - Sync progress indication
  - Retry mechanism for failed syncs
  - Data validation before sync

### 2.3 Data Consistency
- **Status**: Planned
- **Description**: Ensure data integrity across offline and online states
- **Features**:
  - Timestamp tracking for all records
  - Change tracking (created_at, updated_at, deleted_at)
  - Soft delete support
  - Data versioning
  - Sync status indicators per record
  - Rollback capability for failed syncs

---

## Phase 3: Enhanced Features (Future)

### 3.1 Advanced Reporting
- **Status**: Future
- **Description**: Enhanced reporting and analytics
- **Features**:
  - Custom report generation
  - Data export to multiple formats (PDF, Excel, CSV)
  - Chart and visualization improvements
  - Trend analysis

### 3.2 Mobile Optimization
- **Status**: Future
- **Description**: Further mobile UX improvements
- **Features**:
  - Push notifications for important updates
  - Biometric authentication (fingerprint/face)
  - Offline map support
  - Camera integration for photo documentation

### 3.3 Collaboration Features
- **Status**: Future
- **Description**: Team collaboration capabilities
- **Features**:
  - Real-time collaboration on monev entries
  - Comments and notes on records
  - Activity feed
  - Notifications for team updates

---

## Current Implementation Status

### ✅ Completed Features
- Monev summary page with statistics
- Class-level breakdown (Kelas A, B, C, D)
- Activation percentage calculations
- Share functionality (WhatsApp, clipboard)
- Hijriah calendar integration
- Responsive UI for mobile and desktop
- SQLite local database
- Shaf (unit) management
- Monev data entry and editing

### 🔄 In Progress
- None currently

### 📋 Backlog
- Login authorization system
- Offline-first with online sync
- Advanced reporting
- Mobile optimizations
- Collaboration features

---

## Technical Considerations

### Authentication Stack
- Backend: JWT-based authentication
- Frontend: Secure token storage using flutter_secure_storage
- Session management with GetX state management

### Sync Architecture
- Event-driven sync using background_fetch or workmanager
- Conflict resolution middleware
- Change data capture (CDC) pattern
- Optimistic UI updates

### Data Storage
- Primary: SQLite (local)
- Secondary: Backend API (cloud)
- Sync mechanism: REST API or GraphQL

---

## Timeline (Estimated)

| Phase | Feature | Estimated Duration |
|-------|---------|-------------------|
| 1 | Login Authorization | 2-3 weeks |
| 2 | Offline-First Sync | 3-4 weeks |
| 3 | Advanced Features | TBD |

---

## Notes
- All features will maintain backward compatibility with existing data
- User experience and data security are top priorities
- Regular testing and user feedback will guide implementation

