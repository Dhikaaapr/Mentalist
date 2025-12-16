<?php

namespace App\Repositories;

use App\Models\User;

interface UserRepositoryInterface
{
    public function findByEmail(string $email): ?array;
    public function findById(string $id): ?array;
    public function create(array $data): array;
    public function update(string $id, array $data): bool;
    public function delete(string $id): bool;
    public function getUserWithRole(string $id): ?array;
    public function getUserByEmailWithRole(string $email): ?array;
}