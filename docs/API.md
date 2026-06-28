# Ticket Management System API Documentation

Base URL: `http://localhost:3000/api` (development)

Interactive Swagger UI: `http://localhost:3000/api-docs`

## Authentication

All protected endpoints require `Authorization: Bearer <access_token>` header.

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/auth/captcha` | Get captcha challenge | No |
| POST | `/auth/register` | Register citizen (Indian/NRI) | No |
| POST | `/auth/send-otp` | Send OTP to registered mobile | No |
| POST | `/auth/verify-otp` | Verify OTP, get JWT tokens | No |
| POST | `/auth/refresh` | Refresh access token | No |
| GET | `/auth/me` | Get current user profile | Yes |

### Register (Indian Citizen)

```json
POST /auth/register
{
  "registrationType": "INDIAN",
  "mobileNumber": "9876543210",
  "fullName": "Rahul Sharma",
  "fatherName": "Rajesh Sharma",
  "aadhaarNumber": "123456789012",
  "email": "rahul@example.com",
  "gender": "MALE",
  "captchaToken": "...",
  "captchaAnswer": "15"
}
```

### Register (NRI)

```json
POST /auth/register
{
  "registrationType": "NRI",
  "mobileNumber": "9876543210",
  "fullName": "John Doe",
  "fatherName": "James Doe",
  "passportNumber": "A1234567",
  "email": "john@example.com",
  "gender": "MALE",
  "captchaToken": "...",
  "captchaAnswer": "15"
}
```

### Verify OTP Response

```json
{
  "success": true,
  "data": {
    "message": "OTP verified successfully",
    "user": { "id": "...", "mobileNumber": "9876543210", "role": "CITIZEN" },
    "accessToken": "eyJ...",
    "refreshToken": "eyJ..."
  }
}
```

## Master Data

| Method | Endpoint | Description | Role |
|--------|----------|-------------|------|
| GET | `/districts` | List all districts | All |
| POST | `/districts` | Create district | Admin |
| PATCH | `/districts/:id` | Update district | Admin |
| DELETE | `/districts/:id` | Delete district | Admin |
| GET | `/districts/:id/tehsils` | List tehsils | All |
| POST | `/tehsils` | Create tehsil | Admin |
| GET | `/tehsils/:id/projects` | List projects | All |
| POST | `/projects` | Create project | Admin |

## Tickets

| Method | Endpoint | Description | Role |
|--------|----------|-------------|------|
| POST | `/tickets` | Create ticket (multipart) | Citizen |
| GET | `/tickets` | List tickets (role-filtered) | All |
| GET | `/tickets/:id` | Get ticket details | All |
| PATCH | `/tickets/:id/status` | Update status/priority | Agent, Admin |
| PATCH | `/tickets/:id/assign` | Assign to agent | Admin |
| POST | `/tickets/:id/comments` | Add comment | All |
| GET | `/tickets/analytics` | Ticket analytics | Admin |

### Create Ticket (multipart/form-data)

| Field | Type | Required |
|-------|------|----------|
| districtId | UUID | Yes |
| tehsilId | UUID | Yes |
| projectId | UUID | Yes |
| remarks | string (10-2000 chars) | Yes |
| attachments | file[] (jpg/jpeg/png/pdf, max 2MB) | No |

### Status Values

`OPEN`, `ASSIGNED`, `IN_PROGRESS`, `RESOLVED`, `CLOSED`, `REOPENED`

### Priority Values

`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`

## Notifications

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notifications` | List user notifications |
| PATCH | `/notifications/:id/read` | Mark as read |
| PATCH | `/notifications/read-all` | Mark all as read |
| POST | `/notifications/device-token` | Register FCM device token |

## Error Response Format

```json
{
  "success": false,
  "message": "Error description",
  "errors": [{ "field": "mobileNumber", "message": "..." }]
}
```

## Rate Limits

- General API: 100 requests per 15 minutes
- Auth endpoints: 20 requests per 15 minutes
