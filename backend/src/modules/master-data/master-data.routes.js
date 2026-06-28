const { Router } = require('express');
const { MasterDataService } = require('./master-data.service');
const { authenticate, authorize } = require('../../middleware/auth');
const { validate } = require('../../middleware/errorHandler');
const {
  createDistrictSchema,
  createTehsilSchema,
  createProjectSchema,
} = require('../auth/auth.dto');

const router = Router();
const service = new MasterDataService();

/**
 * @swagger
 * /districts:
 *   get:
 *     summary: List all districts
 *     tags: [Master Data]
 */
router.get('/districts', authenticate, async (_req, res, next) => {
  try {
    const districts = await service.listDistricts();
    res.json({ success: true, data: districts });
  } catch (error) {
    next(error);
  }
});

router.post(
  '/districts',
  authenticate,
  authorize('ADMIN'),
  validate(createDistrictSchema),
  async (req, res, next) => {
    try {
      const district = await service.createDistrict(req.validated.body.name);
      res.status(201).json({ success: true, data: district });
    } catch (error) {
      next(error);
    }
  }
);

router.patch(
  '/districts/:id',
  authenticate,
  authorize('ADMIN'),
  async (req, res, next) => {
    try {
      const district = await service.updateDistrict(req.params.id, req.body.name);
      res.json({ success: true, data: district });
    } catch (error) {
      next(error);
    }
  }
);

router.delete(
  '/districts/:id',
  authenticate,
  authorize('ADMIN'),
  async (req, res, next) => {
    try {
      await service.deleteDistrict(req.params.id);
      res.json({ success: true, message: 'District deleted' });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @swagger
 * /districts/{id}/tehsils:
 *   get:
 *     summary: List tehsils for a district
 *     tags: [Master Data]
 */
router.get('/districts/:id/tehsils', authenticate, async (req, res, next) => {
  try {
    const tehsils = await service.listTehsilsByDistrict(req.params.id);
    res.json({ success: true, data: tehsils });
  } catch (error) {
    next(error);
  }
});

router.post(
  '/tehsils',
  authenticate,
  authorize('ADMIN'),
  validate(createTehsilSchema),
  async (req, res, next) => {
    try {
      const { districtId, name } = req.validated.body;
      const tehsil = await service.createTehsil(districtId, name);
      res.status(201).json({ success: true, data: tehsil });
    } catch (error) {
      next(error);
    }
  }
);

router.patch(
  '/tehsils/:id',
  authenticate,
  authorize('ADMIN'),
  async (req, res, next) => {
    try {
      const tehsil = await service.updateTehsil(req.params.id, req.body.name);
      res.json({ success: true, data: tehsil });
    } catch (error) {
      next(error);
    }
  }
);

router.delete(
  '/tehsils/:id',
  authenticate,
  authorize('ADMIN'),
  async (req, res, next) => {
    try {
      await service.deleteTehsil(req.params.id);
      res.json({ success: true, message: 'Tehsil deleted' });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @swagger
 * /tehsils/{id}/projects:
 *   get:
 *     summary: List projects for a tehsil
 *     tags: [Master Data]
 */
router.get('/tehsils/:id/projects', authenticate, async (req, res, next) => {
  try {
    const projects = await service.listProjectsByTehsil(req.params.id);
    res.json({ success: true, data: projects });
  } catch (error) {
    next(error);
  }
});

router.post(
  '/projects',
  authenticate,
  authorize('ADMIN'),
  validate(createProjectSchema),
  async (req, res, next) => {
    try {
      const { tehsilId, name, description } = req.validated.body;
      const project = await service.createProject(tehsilId, name, description);
      res.status(201).json({ success: true, data: project });
    } catch (error) {
      next(error);
    }
  }
);

router.patch(
  '/projects/:id',
  authenticate,
  authorize('ADMIN'),
  async (req, res, next) => {
    try {
      const project = await service.updateProject(req.params.id, req.body);
      res.json({ success: true, data: project });
    } catch (error) {
      next(error);
    }
  }
);

router.delete(
  '/projects/:id',
  authenticate,
  authorize('ADMIN'),
  async (req, res, next) => {
    try {
      await service.deleteProject(req.params.id);
      res.json({ success: true, message: 'Project deleted' });
    } catch (error) {
      next(error);
    }
  }
);

module.exports = router;
