package postgres

import (
	"errors"

	"github.com/X3nonxe/simplebank/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

const (
	foreignKeyViolation = "23503"
	uniqueViolation     = "23505"
)

func translateError(err error) error {
	if err == nil {
		return nil
	}

	if errors.Is(err, pgx.ErrNoRows) {
		return domain.ErrNotFound
	}

	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		switch pgErr.Code {
		case uniqueViolation:
			return domain.ErrConflict
		case foreignKeyViolation:
			return domain.ErrInvalidInput
		}
	}

	return domain.ErrInternal
}
