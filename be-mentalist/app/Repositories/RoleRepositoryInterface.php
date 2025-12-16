<?php

namespace App\Repositories;

interface RoleRepositoryInterface
{
    public function findByName(string $name): ?array;
    public function findById(string $id): ?array;
}