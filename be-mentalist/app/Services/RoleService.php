<?php

namespace App\Services;

use App\Repositories\RoleRepositoryInterface;

class RoleService
{
    protected RoleRepositoryInterface $roleRepository;

    public function __construct(RoleRepositoryInterface $roleRepository)
    {
        $this->roleRepository = $roleRepository;
    }

    /**
     * Get role by name.
     */
    public function getRoleByName(string $name): ?array
    {
        return $this->roleRepository->findByName($name);
    }

    /**
     * Get role by ID.
     */
    public function getRoleById(string $id): ?array
    {
        return $this->roleRepository->findById($id);
    }

    /**
     * Get default user role.
     */
    public function getDefaultUserRole(): ?array
    {
        return $this->getRoleByName('user');
    }
}