const prisma = require('../../utils/prisma');

class MasterDataRepository {
  async getAllDistricts() {
    return prisma.district.findMany({ orderBy: { name: 'asc' } });
  }

  async getDistrictById(id) {
    return prisma.district.findUnique({ where: { id } });
  }

  async createDistrict(name) {
    return prisma.district.create({ data: { name } });
  }

  async updateDistrict(id, name) {
    return prisma.district.update({ where: { id }, data: { name } });
  }

  async deleteDistrict(id) {
    return prisma.district.delete({ where: { id } });
  }

  async getTehsilsByDistrict(districtId) {
    return prisma.tehsil.findMany({
      where: { districtId },
      orderBy: { name: 'asc' },
    });
  }

  async createTehsil(districtId, name) {
    return prisma.tehsil.create({ data: { districtId, name } });
  }

  async updateTehsil(id, data) {
    return prisma.tehsil.update({ where: { id }, data });
  }

  async deleteTehsil(id) {
    return prisma.tehsil.delete({ where: { id } });
  }

  async getProjectsByTehsil(tehsilId) {
    return prisma.project.findMany({
      where: { tehsilId },
      orderBy: { name: 'asc' },
    });
  }

  async createProject(tehsilId, name, description) {
    return prisma.project.create({
      data: { tehsilId, name, description },
    });
  }

  async updateProject(id, data) {
    return prisma.project.update({ where: { id }, data });
  }

  async deleteProject(id) {
    return prisma.project.delete({ where: { id } });
  }
}

class MasterDataService {
  constructor(repository = new MasterDataRepository()) {
    this.repository = repository;
  }

  async listDistricts() {
    return this.repository.getAllDistricts();
  }

  async createDistrict(name) {
    return this.repository.createDistrict(name);
  }

  async updateDistrict(id, name) {
    const district = await this.repository.getDistrictById(id);
    if (!district) {
      const error = new Error('District not found');
      error.status = 404;
      throw error;
    }
    return this.repository.updateDistrict(id, name);
  }

  async deleteDistrict(id) {
    const district = await this.repository.getDistrictById(id);
    if (!district) {
      const error = new Error('District not found');
      error.status = 404;
      throw error;
    }
    return this.repository.deleteDistrict(id);
  }

  async listTehsilsByDistrict(districtId) {
    const district = await this.repository.getDistrictById(districtId);
    if (!district) {
      const error = new Error('District not found');
      error.status = 404;
      throw error;
    }
    return this.repository.getTehsilsByDistrict(districtId);
  }

  async createTehsil(districtId, name) {
    const district = await this.repository.getDistrictById(districtId);
    if (!district) {
      const error = new Error('District not found');
      error.status = 404;
      throw error;
    }
    return this.repository.createTehsil(districtId, name);
  }

  async updateTehsil(id, name) {
    return this.repository.updateTehsil(id, { name });
  }

  async deleteTehsil(id) {
    return this.repository.deleteTehsil(id);
  }

  async listProjectsByTehsil(tehsilId) {
    return this.repository.getProjectsByTehsil(tehsilId);
  }

  async createProject(tehsilId, name, description) {
    return this.repository.createProject(tehsilId, name, description);
  }

  async updateProject(id, data) {
    return this.repository.updateProject(id, data);
  }

  async deleteProject(id) {
    return this.repository.deleteProject(id);
  }
}

module.exports = { MasterDataRepository, MasterDataService };
