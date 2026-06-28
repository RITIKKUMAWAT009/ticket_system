const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  const admin = await prisma.user.upsert({
    where: { mobileNumber: '9999999999' },
    update: {},
    create: {
      mobileNumber: '9999999999',
      fullName: 'System Admin',
      fatherName: 'Admin Father',
      email: 'admin@ticket.gov.in',
      gender: 'MALE',
      role: 'ADMIN',
    },
  });

  const agent1 = await prisma.user.upsert({
    where: { mobileNumber: '8888888888' },
    update: {},
    create: {
      mobileNumber: '8888888888',
      fullName: 'Support Agent One',
      fatherName: 'Agent Father',
      email: 'agent1@ticket.gov.in',
      gender: 'MALE',
      role: 'SUPPORT_AGENT',
    },
  });

  const agent2 = await prisma.user.upsert({
    where: { mobileNumber: '7777777777' },
    update: {},
    create: {
      mobileNumber: '7777777777',
      fullName: 'Support Agent Two',
      fatherName: 'Agent Father',
      email: 'agent2@ticket.gov.in',
      gender: 'FEMALE',
      role: 'SUPPORT_AGENT',
    },
  });

  const citizen = await prisma.user.upsert({
    where: { mobileNumber: '9876543210' },
    update: {},
    create: {
      mobileNumber: '9876543210',
      fullName: 'Rahul Sharma',
      fatherName: 'Rajesh Sharma',
      email: 'rahul@example.com',
      aadhaarNumber: '123456789012',
      gender: 'MALE',
      role: 'CITIZEN',
    },
  });

  const district1 = await prisma.district.upsert({
    where: { name: 'Jaipur' },
    update: {},
    create: { name: 'Jaipur' },
  });

  const district2 = await prisma.district.upsert({
    where: { name: 'Jodhpur' },
    update: {},
    create: { name: 'Jodhpur' },
  });

  const tehsil1 = await prisma.tehsil.upsert({
    where: { districtId_name: { districtId: district1.id, name: 'Jaipur City' } },
    update: {},
    create: { districtId: district1.id, name: 'Jaipur City' },
  });

  const tehsil2 = await prisma.tehsil.upsert({
    where: { districtId_name: { districtId: district1.id, name: 'Amber' } },
    update: {},
    create: { districtId: district1.id, name: 'Amber' },
  });

  const tehsil3 = await prisma.tehsil.upsert({
    where: { districtId_name: { districtId: district2.id, name: 'Jodhpur City' } },
    update: {},
    create: { districtId: district2.id, name: 'Jodhpur City' },
  });

  const project1 = await prisma.project.upsert({
    where: { tehsilId_name: { tehsilId: tehsil1.id, name: 'Water Supply' } },
    update: {},
    create: {
      tehsilId: tehsil1.id,
      name: 'Water Supply',
      description: 'Municipal water supply complaints',
    },
  });

  const project2 = await prisma.project.upsert({
    where: { tehsilId_name: { tehsilId: tehsil1.id, name: 'Road Maintenance' } },
    update: {},
    create: {
      tehsilId: tehsil1.id,
      name: 'Road Maintenance',
      description: 'Road repair and maintenance complaints',
    },
  });

  const project3 = await prisma.project.upsert({
    where: { tehsilId_name: { tehsilId: tehsil2.id, name: 'Electricity' } },
    update: {},
    create: {
      tehsilId: tehsil2.id,
      name: 'Electricity',
      description: 'Power supply related complaints',
    },
  });

  const ticket = await prisma.ticket.upsert({
    where: { ticketNumber: 'TKT-20260001' },
    update: {},
    create: {
      ticketNumber: 'TKT-20260001',
      citizenId: citizen.id,
      districtId: district1.id,
      tehsilId: tehsil1.id,
      projectId: project1.id,
      remarks: 'No water supply in Ward 12 for 3 days',
      status: 'ASSIGNED',
      priority: 'HIGH',
      assignedAgentId: agent1.id,
    },
  });

  await prisma.ticketComment.upsert({
    where: { id: '00000000-0000-0000-0000-000000000001' },
    update: {},
    create: {
      id: '00000000-0000-0000-0000-000000000001',
      ticketId: ticket.id,
      userId: citizen.id,
      message: 'Please resolve urgently.',
    },
  });

  console.log('Seed completed:');
  console.log(`  Admin: ${admin.mobileNumber}`);
  console.log(`  Agents: ${agent1.mobileNumber}, ${agent2.mobileNumber}`);
  console.log(`  Citizen: ${citizen.mobileNumber}`);
  console.log(`  Districts: 2, Tehsils: 3, Projects: 3`);
  console.log(`  Sample ticket: ${ticket.ticketNumber}`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
